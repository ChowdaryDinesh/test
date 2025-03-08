terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "vpc1" {
  cidr_block = "172.31.0.0/16"
  tags = {
    name = "dinesh_vpc"

  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "igw vpc1"
  }
}


resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "172.31.1.0/24"

  tags = {
    Name = "private_subnet"
  }
}
resource "aws_subnet" "public_subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "172.31.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "public subnet"
  }
}
resource "aws_subnet" "public_subnet2" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "172.31.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
    Name = "public subnet"
  }

}

# public route table on public subnet
resource "aws_route_table" "public_rt_table" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    name = "public_rt_table"
  
}
}
# private route table

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.vpc1.id
   
    tags = {
        name = "private_rt_table"
    }
}

# route table association

resource "aws_route_table_association" "public_rt_asso1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt_table.id
}
resource "aws_route_table_association" "public_rt_asso2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt_table.id
}


resource "aws_route_table_association" "private_rt_asso" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# security group -- on public subnet 
resource "aws_security_group" "public_sg" {
    vpc_id = aws_vpc.vpc1.id
    name = "public sg"
    tags = {
        Name = "public_sg"
    }
}


resource "aws_security_group_rule" "allow_all_traffic_ipv4" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_sg.id
}



resource "aws_security_group" "private_sg" {
    vpc_id = aws_vpc.vpc1.id
    name = "private sg"
    tags = {
        Name = "private_sg"
    }
}


resource "aws_security_group_rule" "all_traffic_ipv4" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = [aws_subnet.private_subnet.cidr_block]
  security_group_id = aws_security_group.public_sg.id
}
######################

# load balancer

resource "aws_security_group" "lb_sg" {
vpc_id = aws_vpc.vpc1.id

ingress {
from_port = 8000
to_port = 8000
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_lb" "hello" {
    name = "helloapp-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.lb_sg.id]
    subnets = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

    enable_deletion_protection = true


    tags = {
        env = "dev"
    }
}

resource "aws_lb_target_group" "testlbtg" {
  name     = "testlbtg1"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc1.id
  ip_address_type = "ipv4"
  target_type = "ip"
}

resource "aws_lb_listener" "testlblistener" {
  load_balancer_arn = aws_lb.hello.arn
  port              = "8000"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.testlbtg.arn
  }
}

#####################
# ecs cluster and task definition


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
  execution_role_arn = aws_iam_role.ecsInstanceRole.arn
}

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

# ecr

resource "aws_ecr_repository" "testrepo" {
  name                 = "testrepodi"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# monitoring

# resource "aws_iam_policy" "monitorpolicy" {
#   name        = "nonitorolicy"
#   path        = "/"
#   description = "My ecr policy"

#   policy = jsonencode(
#     {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "logs:CreateLogGroup",
#                 "logs:CreateLogStream",
#                 "logs:PutLogEvents",
#                 "logs:DescribeLogStreams"
#             ],
#             "Resource": ["arn:aws:logs:*:*:*"]
#         }
#     ]
#     })
# }


