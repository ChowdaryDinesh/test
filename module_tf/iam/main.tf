
# aws ecs service 
data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
    name = "AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy" "lb_p" {
  name = "lbpolicy"
  path = "/"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:*",
                "elasticloadbalancing:*",
                "application-autoscaling:*",
                "resource-groups:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
})
}
resource "aws_iam_policy" "ecrpolicy" {
  name        = "ecrpolicy1"
  path        = "/"
  description = "My ecr policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_role" "ecsInstanceRole" {
    name = "ecsRole1"
    assume_role_policy = jsonencode({
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Principal":{
            "Service":[
               "ecs.amazonaws.com",
               "ecs-tasks.amazonaws.com"
            ]
         },
         "Action":"sts:AssumeRole"
      }
   ]
})
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.ecsInstanceRole.name
  policy_arn = aws_iam_policy.ecrpolicy.arn
}
resource "aws_iam_role_policy_attachment" "lp" {
  role       = aws_iam_role.ecsInstanceRole.name
  policy_arn = aws_iam_policy.lb_p.arn
}

resource "aws_iam_role_policy_attachment" "service_policy" {
  role       = aws_iam_role.ecsInstanceRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
// arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
resource "aws_iam_role_policy_attachment" "ecr_policy2" {
  role       = aws_iam_role.ecsInstanceRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# resource "aws_ecs_service" "python_hello" {
#   name            = "python_hello"
#   cluster         = aws_ecs_cluster.ecs_cluster1.id
#   task_definition = aws_ecs_task_definition.test.arn
#   desired_count   = 2
#   iam_role = aws_iam_role.ecsInstanceRole.arn
#   load_balancer {
#     target_group_arn = aws_lb_target_group.testlbtg.arn
#     container_name   = "helloapp"
#     container_port   = 8000
#   }
# }