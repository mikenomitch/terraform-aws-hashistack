locals {
  consul_base_config = {
    consul_version  = var.consul_version
    datacenter      = var.region
    min_servers     = var.min_servers
    region          = var.region
    retry_provider  = var.retry_join.provider
    retry_tag_key   = var.retry_join.tag_key
    retry_tag_value = var.retry_join.tag_value
  }

  nomad_base_config = {
    datacenter      = var.region
    min_servers     = var.min_servers
    nomad_version   = var.nomad_version
    region          = var.region
    retry_provider  = var.retry_join.provider
    retry_tag_key   = var.retry_join.tag_key
    retry_tag_value = var.retry_join.tag_value
  }

  consul_server_config = templatefile("${path.module}/templates/consul.sh.tpl", merge(local.consul_base_config, {is_server = true}))
  consul_client_config = templatefile("${path.module}/templates/consul.sh.tpl", merge(local.consul_base_config, {is_server = false}))

  nomad_server_config = templatefile("${path.module}/templates/nomad.sh.tpl", merge(local.nomad_base_config, {is_server = true}))
  nomad_client_config = templatefile("${path.module}/templates/nomad.sh.tpl", merge(local.nomad_base_config, {is_server = false}))
  docker_config = templatefile("${path.module}/templates/docker.sh.tpl", {})
  consul_template_config = templatefile("${path.module}/templates/consul_template.sh.tpl", {})

  launch_base_user_data = {
    consul_config          = local.consul_client_config
    consul_template_config = local.consul_template_config
    docker_config          = local.docker_config
    nomad_config           = local.nomad_client_config
  }
}

resource "aws_launch_configuration" "hashistack_server_launch" {
  name   = "hashistack-server"
  image_id      = var.base_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  security_groups             = [aws_security_group.lc_security_group.id]
  associate_public_ip_address = var.associate_public_ip_address

  user_data = templatefile(
    "${path.module}/templates/startup.sh.tpl",
    merge(local.launch_base_user_data, {is_server = true})
  )
}

resource "aws_launch_configuration" "hashistack_client_launch" {
  name   = "hashistack-client"
  image_id      = var.base_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  security_groups             = [aws_security_group.lc_security_group.id]
  associate_public_ip_address = var.associate_public_ip_address

  user_data = templatefile(
    "${path.module}/templates/startup.sh.tpl",
    merge(local.launch_base_user_data, {is_server = false})
  )
}

resource "aws_autoscaling_group" "hashistack_server_asg" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 2
  max_size           = var.max_servers
  min_size           = var.min_servers

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-server"
      propagate_at_launch = true
    },
    {
      key                 = var.retry_join.tag_key
      value               = var.retry_join.tag_value
      propagate_at_launch = true
    }
  ]

  launch_configuration = "${aws_launch_configuration.hashistack_server_launch.name}"
}

resource "aws_autoscaling_group" "hashistack_client_asg" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 2
  max_size           = var.max_servers
  min_size           = var.min_servers

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-client"
      propagate_at_launch = true
    },
    {
      key                 = var.retry_join.tag_key
      value               = var.retry_join.tag_value
      propagate_at_launch = true
    }
  ]

  launch_configuration = "${aws_launch_configuration.hashistack_client_launch.name}"
}
