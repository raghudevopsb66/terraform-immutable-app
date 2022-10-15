resource "aws_launch_template" "launch-template" {
  name     = "${var.COMPONENT}-${var.ENV}"
  image_id = data.aws_ami.ami.image_id

  instance_market_options {
    market_type = "spot"
  }

  instance_type = "t2.micro"


  vpc_security_group_ids = [aws_security_group.main.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.COMPONENT}-${var.ENV}"
    }
  }

  tag_specifications {
    resource_type = "spot-instances-request"
    tags = {
      Name = "${var.COMPONENT}-${var.ENV}"
    }
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    ENV                    = var.ENV
    COMPONENT              = var.COMPONENT
    DOCDB_ENDPOINT         = var.DOCDB_ENDPOINT
    DOCDB_USER             = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)["DOCDB_USER"]
    DOCDB_PASS             = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)["DOCDB_PASS"]
    RABBITMQ_USER_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)["RABBITMQ_USER_PASSWORD"]
    MYSQL_ENDPOINT         = var.MYSQL_ENDPOINT
    REDIS_ENDPOINT         = var.REDIS_ENDPOINT
  }))
}

resource "aws_autoscaling_group" "bar" {
  vpc_zone_identifier = data.terraform_remote_state.infra.outputs.app_subnets
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  target_group_arns   = [aws_lb_target_group.tg.*.arn[0]]

  launch_template {
    id      = aws_launch_template.launch-template.id
    version = "$Latest"
  }
}
