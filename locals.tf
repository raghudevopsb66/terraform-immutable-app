locals {
  ssh_password = element(split("/", data.aws_ssm_parameter.ssh_credentials.value), 1)
  ssh_username = element(split("/", data.aws_ssm_parameter.ssh_credentials.value), 0)
}


