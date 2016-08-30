# provider configuration
provider "aws" {
  access_key  = ""
  secret_key  = ""
  shared_credentials_file = ""
  profile     = ""
  region      = "us-west-2"
  max_retries = "10"
} 

# AWS VPC block
resource "aws_vpc" "lambda_test_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "lambda_test_vpc"
  }
}

# A VPC-only route53 zone and record
resource "aws_route53_zone" "private_zone" {
  name     = "lambda-test.internal"
  comment  = "A VPC-only zone for lambda test"
  vpc_id   = "${aws_vpc.lambda_test_vpc.id}"
  force_destroy = true
}

# DHCP options sets
resource "aws_vpc_dhcp_options" "vpc_dhcp" {
  domain_name         = "lambda-test.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "lambda_test_dhcp"
  }
}

# DHCP association
resource "aws_vpc_dhcp_options_association" "vpc_dhcp_association" {
  vpc_id          = "${aws_vpc.lambda_test_vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.vpc_dhcp.id}"
}

# all defined subnets
resource "aws_subnet" "vpc_subnet_uwswest2a" {
  vpc_id                  = "${aws_vpc.lambda_test_vpc.id}"
  cidr_block              = "10.0.1.0/22"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags {
    Name = "vv_subnet"
  }
}

# information on CoreOS AMIs for etcd nodepools
resource "coreosbox_ami" "lambda_test_ami" {
  channel        = "beta"
  virtualization = "hvm"
  region         = "us-west-2"
  version        = "current"
}

# Launch configurations for all etcd clusters
resource "aws_launch_configuration" "lambda_test_config" {
  name                        = "lambda_test_launch_config"
  image_id                    = "${coreosbox_ami.lambda_test_ami.box_string}"
  instance_type               = "t2.micro"
  associate_public_ip_address = false
}

# IAM role for lambda functions that will modify DNS records
data "aws_iam_policy_document" "lambda_test_role_doc" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}
resource "aws_iam_role" "lambda_test_role" {
    name = "lambda_test_etcd_role"
    assume_role_policy = "${data.aws_iam_policy_document.lambda_test_role_doc.json}"
}

# IAM role policy for lambda functions that will modify DNS records
data "aws_iam_policy_document" "lambda_test_role_policy_doc" {
  statement {
    actions = [
      "ec2:Describe*",
      "ec2:CreateTags",
      "autoscaling:Describe*",
      "route53:*"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*",
    ]
    effect = "Allow"
  }
}
resource "aws_iam_role_policy" "lambda_test_role_policy" {
  name = "lambda_test_etcd_role_policy"
  role = "${aws_iam_role.lambda_test_role.id}"
  policy = "${data.aws_iam_policy_document.lambda_test_role_policy_doc.json}"
}

# IAM role for SNS topic subscription
data "aws_iam_policy_document" "iam_lambda_sns_role_doc" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = ["autoscaling.amazonaws.com"]
    }
    effect = "Allow"
  }
}
resource "aws_iam_role" "lambda_test_sns_role" {
  name = "lambda_test_sns_role"
  assume_role_policy = "${data.aws_iam_policy_document.iam_lambda_sns_role_doc.json}"
}

# IAM role policy for for sns events publishing
data "aws_iam_policy_document" "lambda_test_event_role_policy_doc" {
  statement {
    actions = [
      "sns:Publish",
    ]
    resources = [
      "${aws_sns_topic.lambda_test_scaling_events.arn}",
    ]
    effect = "Allow"
  }
}
resource "aws_iam_role_policy" "lambda_test_event_role_policy" {
  name = "lambda_test_event_role_policy"
  role = "${aws_iam_role.lambda_test_sns_role.id}"
  policy = "${data.aws_iam_policy_document.lambda_test_event_role_policy_doc.json}"
}

# SNS resources for etcd clusters
resource "aws_sns_topic" "lambda_test_scaling_events" {
  name = "lambda_test_events"
}

# Lambda function that will setup all dns records for etcd discovery
resource "aws_lambda_function" "lambda_test_lambda" {
  filename = "lambda-sns-etcd-service-discovery.zip"
  function_name = "lambda_test"
  role = "${aws_iam_role.lambda_test_role.arn}"
  handler = "lambda-sns-etcd-service-discovery.handler"
  runtime = "python2.7"
  timeout = 300
}

resource "aws_lambda_permission" "lambda_test_permission" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_test_lambda.arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.lambda_test_scaling_events.arn}"
}

resource "aws_sns_topic_subscription" "lambda_test_subscription" {
  topic_arn = "${aws_sns_topic.lambda_test_scaling_events.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.lambda_test_lambda.arn}"
}

# Autoscaling groups for all etcd clusters
resource "aws_autoscaling_group" "lambda_test_nodes" {
  name                      = "lambda_test_asg"
  vpc_zone_identifier       = ["${aws_subnet.vpc_subnet_uwswest2a.id}"]
  launch_configuration      = "${aws_launch_configuration.lambda_test_config.name}"
  wait_for_capacity_timeout = "0"
  force_delete              = true
  health_check_grace_period = "30"
  max_size                  = "3"
  min_size                  = "3"
  desired_capacity          = "3"
  health_check_type         = "EC2"

  tag {
    key                 = "DomainConfig"
    value               = "${aws_route53_zone.private_zone.zone_id}:lambda-test.internal:prefix:_etcd-client-ssl._tcp:_etcd-server-ssl._tcp:2380"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "lambda_test-autoscaled"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_notification" "lambda_test_notifications" {
  group_names = [
    "${aws_autoscaling_group.lambda_test_nodes.name}"
  ]
  notifications  = [
    "autoscaling:EC2_INSTANCE_LAUNCH", 
    "autoscaling:EC2_INSTANCE_TERMINATE"
  ]
  topic_arn = "${aws_sns_topic.lambda_test_scaling_events.arn}"
}
