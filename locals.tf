locals {
  ssh_password = element(split("/", data.aws_ssm_parameter.ssh_credentials.value), 1)
  ssh_username = element(split("/", data.aws_ssm_parameter.ssh_credentials.value), 0)

  username = element(split("/", data.aws_ssm_parameter.credentials.value), 0)
  password = element(split("/", data.aws_ssm_parameter.credentials.value), 1)

  //arn = aws_lb_target_group.tg.*.arn[0]
  arn = var.COMPONENT == "frontend" ? data.terraform_remote_state.infra.outputs.public_tg_arn : aws_lb_target_group.tg.*.arn[0]

}