variable "controller_subnets" {
  type        = "list"
  description = "A list of subnets to create controller servers in."
}

variable "security_groups" {
  type        = "list"
  description = "A list of security groups to join the controllers to."
}

resource "aws_network_interface" "controller" {
  count       = "${length(var.controller_subnets)}"
  subnet_id   = "${element(var.controller_subnets, count.index)}"
  description = "${format("controller%02-d.%s.%s", count.index, data.aws_region.current.name, var.domain_name)}"

  security_groups = [
    "${var.security_groups}",
  ]

  tags {
    Name     = "kube-controller-${count.index + 1}"
    Owner    = "infrastructure"
    Billing  = "costcenter"
    Hostname = "${format("controller%02-d.%s.%s", count.index, data.aws_region.current.name, var.domain_name)}"
  }
}
