resource "aws_launch_configuration" "hashistack_launch" {
  name   = "hashistack"
  image_id      = var.base_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  security_groups = [aws_security_group.lc_security_group.id]
  associate_public_ip_address = var.associate_public_ip_address

  user_data = templatefile(
    "${path.module}/templates/startup.sh.tpl",
    {
      consul_version = "${var.consul_version}",
      datacenter = "${var.region}"
      min_servers = "${var.min_servers}"
      nomad_version = "${var.nomad_version}",
      region = "${var.region}"
      to_echo = "${var.to_echo}",
      to_touch = "${var.to_touch}",
    }
  )
}

resource "aws_autoscaling_group" "hashistack_asg" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = var.max_servers
  min_size           = var.min_servers

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}"
      propagate_at_launch = true
    }
  ]

  launch_configuration = "${aws_launch_configuration.hashistack_launch.name}"
}
