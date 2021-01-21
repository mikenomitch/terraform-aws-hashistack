resource "aws_iam_role_policy" "mount_ebs_volumes" {
  name   = "mount-ebs-volumes"
  role   = aws_iam_role.auto-join.id
  policy = data.aws_iam_policy_document.mount_ebs_volumes.json
}

data "aws_iam_policy_document" "mount_ebs_volumes" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
    ]
    resources = ["*"]
  }
}

resource "aws_ebs_volume" "psql" {
  availability_zone = var.availability_zones[var.region][0]
  size              = 40
}
