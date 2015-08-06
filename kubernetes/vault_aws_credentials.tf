module "vault_aws_credentials" {
  source = "./tf_modules/vault_aws"
  github_token = "${var.github_org_token}"
}