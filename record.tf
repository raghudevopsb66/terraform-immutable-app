resource "aws_route53_record" "private" {
  zone_id = data.aws_route53_zone.private.id
  name    = "${var.COMPONENT}-${var.ENV}.roboshop.internal"
  type    = "CNAME"
  ttl     = 30
  records = [data.terraform_remote_state.infra.outputs.private_lb_dns_name]
}
