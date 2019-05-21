provider "aws" {
  region  = var.region
}

resource "aws_instance" "web" {
  ami           = var.base_ami
  instance_type = var.instance_type
  key_name      = "nomad"
}
