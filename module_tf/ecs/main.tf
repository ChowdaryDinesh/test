
resource "aws_ecs_cluster" "ecs_cluster1" {
  name = "ecs_cluster1"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
# ecs iam 
# data "aws_iam_policy" "ecs_full_access" {
#     name = "AmazonECSTaskExecutionRolePolicy"

# }
# resource "aws_iam_role" "ecsTaskExecutionRole" {
#     name = "ecsTaskExecutionRole"
#     assume_role_policy = data.aws_iam_policy.ecs_full_access.json
# }

resource "aws_ecs_task_definition" "test" {
  family                   = "test"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions = file("task_definitions/test.json")
  execution_role_arn = var.ecsInstanceRole_arn
}

