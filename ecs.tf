resource "aws_ecs_cluster" "nomad_remote_driver_demo" {
  name = "nomad-remote-driver-cluster"
}

resource "aws_ecs_task_definition" "nomad_remote_driver_demo" {
  family                   = "nomad-remote-driver-cluster"
  container_definitions    = file(var.ecs_task_definition_file)
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
}

resource "aws_iam_role_policy" "do_ecs_stuff" {
  name   = "do-ecs-stuff"
  role   = aws_iam_role.auto-join.id
  policy = data.aws_iam_policy_document.mount_ebs_volumes.json
}

data "aws_iam_policy_document" "do_ecs_stuff" {
  statement {
    effect = "Allow"

    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeTasks",
      "ecs:ListClusters",
      "ecs:RunTask",
      "ecs:StopTask",
    ]
    resources = ["*"]
  }
}