// == VERSIONS ==

variable "nomad_version" {
  type = string
  default = "0.9.1"
}

variable "consul_version" {
  type = string
  default = "1.4.4"
}

// == HIGH LEVEL AWS INFO ==

variable "region" {
  type = string
  default = "us-east-1"
}

// == SECURITY ==

variable "vpc_id" {
  type = string
  default = ""
}

// PORTS

variable "serf_port" {
  type = string
  default = "4646"
}

variable "ssh_port" {
  type = string
  default = "4646"
}

variable "rpc_port" {
  type = string
  default = "4003"
}

variable "http_port" {
  type = string
  default = "4000"
}

// CIDR

variable "allowed_inbound_cidr_blocks" {
  type = string
  default = "0.0.0.0/0"
}

variable "allowed_ssh_cidr_blocks" {
  type = string
  default = "0.0.0.0/0"
}


// == ALB ==

variable "base_ami" {
  type = string
  default = "ami-024a64a6685d05041"
  description = "The id of the machine image (AMI) to use for the server. Uses the US East-1 AMI for Ubuntu 18.0.4 LTS AMD 64"
}

variable "key_name" {
  type = string
  default = "nomad"
}

variable "instance_type" {
  type = string
  default = "t2.nano"
}

variable "max_servers" {
  type = number
  default = 2
}

variable "min_servers" {
  type = number
  default = 1
}

variable "cluster_name" {
  type = string
  default = "hashistack"
}

variable "associate_public_ip_address" {
  type = bool
  default = true
}

// == SERVER DATA ==

variable "to_touch" {
  type = string
  default = "foo"
}

variable "to_echo" {
  type = string
  default = "bar"
}
