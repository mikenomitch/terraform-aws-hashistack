provider "aws" {
  region  = var.region
}

resource "aws_launch_configuration" "hashistack_launch" {
  name   = "hashistack_launch"
  image_id      = var.base_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = templatefile(
    "${path.module}/templates/startup.sh.tpl",
    {
      to_touch = "${var.to_touch}",
      to_echo = "${var.to_echo}"
    }
  )
}

resource "aws_autoscaling_group" "bar" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = var.max_servers
  min_size           = var.min_servers

  launch_configuration = "${aws_launch_configuration.hashistack_launch.name}"
}
