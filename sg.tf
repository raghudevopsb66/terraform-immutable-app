resource "aws_security_group" "main" {
  name        = "${var.ENV}-${var.COMPONENT}"
  description = "${var.ENV}-${var.COMPONENT}"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.infra.outputs.vpc_cidr, data.terraform_remote_state.infra.outputs.workstation_ip]
  }

  ingress {
    description = "APP"
    from_port   = var.APP_PORT
    to_port     = var.APP_PORT
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.infra.outputs.vpc_cidr]
  }

  ingress {
    description = "PROMETHEUS"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.PROMETHEUS_IP]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ENV}-${var.COMPONENT}"
  }
}