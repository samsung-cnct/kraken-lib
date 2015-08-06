variable "github_token" {}

variable "vault_url" {
  default = "https://vault.kubeme.io/v1"
}

variable "vault_github_mount" {
  default = "github"
}

variable "vault_creds_role" {
  default = "root"
}

variable "vault_aws_mount" {
  default = "root"
}

resource "template_file" "aws_creds" {
  filename = "${path.module}/dummy.tpl"

  # get the vault auth token into a file
  provisioner "local-exec" {
    command = "curl --request POST --url ${var.vault_url}/auth/${var.vault_github_mount}/login --header 'content-type: application/json' --data '{ \"token\": \"${var.github_token}\"}' --insecure | jq '.auth.client_token' > auth_token.tf.temp"
  }

  # save creds into file
  provisioner "local-exec" {
    command = "curl --request GET --url https://vault.kubeme.io/v1/${var.vault_aws_mount}/creds/${var.vault_creds_role} --header 'x-vault-token: ${file("auth_token.tf.temp")}' > full_creds.tf.temp"
  }

  # parse creds into two separate files
  provisioner "local-exec" {
    command = "cat full_creds.tf.temp | jq '.data.access_key' > access_key.tf.temp"
  }

  provisioner "local-exec" {
    command = "cat full_creds.tf.temp | jq '.data.access_key' > secret_key.tf.temp"
  }
}

output "aws_key_id" {
  value = "${file("access_key.tf.temp")}"
}

output "aws_secret_key" {
  value = "${file("secret_key.tf.temp")}"
}