locals {
  docker_config = templatefile("${path.module}/templates/docker.sh.tpl", {})
  consul_config = templatefile("${path.module}/templates/consul.sh.tpl", {
    consul_version  = var.consul_version
    datacenter      = var.region
    min_servers     = var.min_servers
    region          = var.region
    retry_provider  = var.retry_join.provider
    retry_tag_key   = var.retry_join.tag_key
    retry_tag_value = var.retry_join.tag_value
  })

  consul_template_config = templatefile("${path.module}/templates/consul_template.sh.tpl", {})

  nomad_config = templatefile("${path.module}/templates/nomad.sh.tpl", {
    datacenter    = var.region
    min_servers   = var.min_servers
    nomad_version = var.nomad_version
    region        = var.region
  })
}

resource "aws_launch_configuration" "hashistack_launch" {
  name   = "hashistack"
  image_id      = var.base_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  security_groups             = [aws_security_group.lc_security_group.id]
  associate_public_ip_address = var.associate_public_ip_address

  user_data = templatefile(
    "${path.module}/templates/startup.sh.tpl",
    {
      consul_config          = local.consul_config
      consul_template_config = local.consul_template_config
      docker_config          = local.docker_config
      nomad_config           = local.nomad_config
    }
  )
}

resource "aws_autoscaling_group" "hashistack_asg" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 2
  max_size           = var.max_servers
  min_size           = var.min_servers

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}"
      propagate_at_launch = true
    },
    {
      key                 = var.retry_join.tag_key
      value               = var.retry_join.tag_value
      propagate_at_launch = true
    }
  ]

  launch_configuration = "${aws_launch_configuration.hashistack_launch.name}"
}
