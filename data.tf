data "aws_ssm_parameter" "ssh_credentials" {
  name = "ssh.credentials"
}

data "aws_ami" "ami" {
  most_recent = true
  name_regex  = "${var.COMPONENT}-${var.APP_VERSION}"
  owners      = ["self"]
}

data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = "terraform-b66"
    key    = "mutable/infra/${var.ENV}/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_route53_zone" "private" {
  name         = "roboshop.internal"
  private_zone = true
}

data "aws_ssm_parameter" "credentials" {
  name = "mutable.docdb.${var.ENV}.credentials"
}

data "aws_ssm_parameter" "docdb-endpoint" {
  name = "immutable.docdb.endpoint"
}

data "aws_ssm_parameter" "redis-endpoint" {
  name = "immutable.redis.endpoint"
}

