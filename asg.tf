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
  vpc_zone_identifier = data.terraform_remote_state.infra.outputs.app_subnets[count.index]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}
