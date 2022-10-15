variable "COMPONENT" {}
variable "ENV" {}
variable "INSTANCES" {}
variable "APP_PORT" {}
variable "LB_RULE_PRIORITY" {
  default = 1000
}
variable "PROMETHEUS_IP" {
  default = "172.31.9.152/32"
}

variable "APP_VERSION" {}
