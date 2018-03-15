variable "coreos_ami" {
  type        = "map"
  description = "CoreOS AMI to use for creating our controllers."

  default = {
    "ap-northeast-1" = "ami-884835ee"
    "ap-northeast-2" = "ami-1455f77a"
    "ap-south-1"     = "ami-991845f6"
    "ap-southeast-1" = "ami-b9c280c5"
    "ap-southeast-2" = "ami-04be7b66"
    "ca-central-1"   = "ami-9e7cf8fa"
    "eu-central-1"   = "ami-862140e9"
    "eu-west-1"      = "ami-a61464df"
    "eu-west-2"      = "ami-3e0eeb59"
    "eu-west-3"      = "ami-1f9d2b62"
    "sa-east-1"      = "ami-022d646e"
    "us-east-1"      = "ami-3f061b45"
    "us-east-2"      = "ami-85ffcbe0"
    "us-west-1"      = "ami-cc0900ac"
    "us-west-2"      = "ami-692faf11"
  }
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
  ami                  = "${var.coreos_ami[data.aws_region.current.name]}"
  instance_type        = "${var.instance_type}"
  key_name             = "kubernetes"
  iam_instance_profile = "${var.instance_profile}"

  tags {
    Name            = "kuberform-controller-${count.index + 1}"
    Owner           = "infrastructure"
    Billing         = "costcenter"
    OperatingSystem = "coreos"
    AMI             = "${var.coreos_ami[data.aws_region.current.name]}"
    Hostname        = "${format("controller%02-d.%s.%s", count.index, data.aws_region.current.name, var.domain_name)}"
  }

  volume_tags {
    Name    = "kuberform-controller-volume-${count.index + 1}"
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
