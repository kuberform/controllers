variable "coreos_ami" {
  type        = "string"
  description = "CoreOS AMI to use for creating our controllers."
}

variable "instance_type" {
  type        = "string"
  description = "Instance size to use for creating CoreOS controllers."
  default     = "t2.large"
}

variable "disk_size" {
  type        = "string"
  description = "The size of the CoreOS disk to launch for the controllers."
  default     = 75
}

variable "domain_name" {
  type        = "string"
  description = "The domain name that this cluster is being built upon."
}

resource "aws_instance" "controller" {
  count                = "${length(var.controller_subnets)}"
  ami                  = "${var.coreos_ami}"
  instance_type        = "${var.instance_type}"
  key_name             = "kubernetes"
  iam_instance_profile = "${var.instance_profile}"

  tags {
    Name            = "kube-controller-${count.index + 1}"
    Owner           = "infrastructure"
    Billing         = "costcenter"
    OperatingSystem = "coreos"
    AMI             = "${var.coreos_ami}"
    Hostname        = "${format("controller%02-d.%s.%s", count.index, data.aws_region.current.name, var.domain_name)}"
  }

  volume_tags {
    Name    = "kube-controller-volume-${count.index + 1}"
    Owner   = "infrastructure"
    Billing = "costcenter"
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.disk_size}"

    delete_on_termination = true
  }

  network_interface {
    device_index         = 0
    network_interface_id = "${element(aws_network_interface.controller.*.id, count.index)}"

    delete_on_termination = false
  }
}
