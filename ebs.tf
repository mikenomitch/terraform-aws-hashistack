resource "aws_ebs_volume" "example" {
  availability_zone = "us-east-1a"
  size              = 30

  tags = {
    Name = "DemoVolume"
  }
}
