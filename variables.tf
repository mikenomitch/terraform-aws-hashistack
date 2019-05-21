variable "base_ami" {
  type = string
  default = "ami-024a64a6685d05041"
  description = "The id of the machine image (AMI) to use for the server. Uses the US East-1 AMI for Ubuntu 18.0.4 LTS AMD 64"
}

variable "instance_type" {
  type = string
  default = "t2.nano"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "max_servers" {
  type = number
  default = 2
}

variable "min_servers" {
  type = number
  default = 1
}