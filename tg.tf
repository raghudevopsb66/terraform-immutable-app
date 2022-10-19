resource "aws_lb_target_group" "tg" {
  count                = var.COMPONENT == "frontend" ? 0 : 1
  name                 = "${var.COMPONENT}-${var.ENV}"
  port                 = var.APP_PORT
  protocol             = "HTTP"
  vpc_id               = data.terraform_remote_state.infra.outputs.vpc_id
  deregistration_delay = 60
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 5
    timeout             = 4
    port                = var.APP_PORT
    unhealthy_threshold = 2
    path                = "/health"
  }
}

resource "aws_lb_listener_rule" "name-based-rule" {
  count        = var.COMPONENT == "frontend" ? 0 : 1
  listener_arn = data.terraform_remote_state.infra.outputs.private_lb_listener_arn
  priority     = var.LB_RULE_PRIORITY

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[0].arn
  }

  condition {
    host_header {
      values = ["${var.COMPONENT}-${var.ENV}.roboshop.internal"]
    }
  }
}


