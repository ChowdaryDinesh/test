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

module "vpc" {
    source = "vpc"
}
module "iam" {
    source = "iam"
}
module "lb" {
    source = "lb"
    aws_vpc_id = module.vpc.vpc_id
    lb_sg_id = module.vpc.lb_sg_id
    ps1id = module.vpc.ps1id
    ps2id = module.vpc.ps2id
}
module "ecr" {
    source = "ecr"
}
module "ecs" {
    source = "ecs"
    ecsInstanceRole_arn = module.iam.ecsInstanceRole_arn
}