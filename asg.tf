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

  //user_data = filebase64("${path.module}/example.sh")
}

resource "aws_autoscaling_group" "bar" {
  vpc_zone_identifier = data.terraform_remote_state.infra.outputs.app_subnets
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  target_group_arns   = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.launch-template.id
    version = "$Latest"
  }
}
