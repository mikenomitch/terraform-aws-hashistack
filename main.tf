provider "aws" {
  region  = var.region
}

data "template_file" "startup" {
  template = "${file("${path.module}/templates/startup.sh.tpl")}"

  vars {
    to_touch = "${var.to_touch}"
    to_echo = "${var.to_echo}"
  }
}


resource "aws_launch_template" "hashistack_launch_template" {
  name_prefix   = "hashistack"
  image_id      = var.base_ami
  instance_type = var.instance_type
}

resource "aws_autoscaling_group" "bar" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = var.max_servers
  min_size           = var.min_servers

  launch_template {
    id      = "${aws_launch_template.hashistack_launch_template.id}"
    version = "$Latest"
  }
}
