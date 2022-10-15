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
    ENV            = var.ENV
    COMPONENT      = var.COMPONENT
    REDIS_ENDPOINT = data.aws_ssm_parameter.redis-endpoint.value
    DOCDB_ENDPOINT = data.aws_ssm_parameter.docdb-endpoint.value
    DOCDB_USER     = local.username
    DOCDB_PASS     = local.password
    MYSQL_ENDPOINT = ""
    REDIS_ENDPOINT = ""
  }))
}

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = "echo REDIS ENDPOINT = ${data.aws_ssm_parameter.redis-endpoint.value}"
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.COMPONENT}-${var.ENV}"
  vpc_zone_identifier = data.terraform_remote_state.infra.outputs.app_subnets
  desired_capacity    = 1
  max_size            = var.max_size
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.tg.*.arn[0]]

  launch_template {
    id      = aws_launch_template.launch-template.id
    version = "$Latest"
  }
}
