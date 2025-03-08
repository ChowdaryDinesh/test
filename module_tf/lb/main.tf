
resource "aws_security_group" "lb_sg" {
vpc_id = var.aws_vpc_id

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
    security_groups = [var.lb_sg_id]
    subnets = [var.ps2id, var.ps1id]

    enable_deletion_protection = true


    tags = {
        env = "dev"
    }
}

resource "aws_lb_target_group" "testlbtg" {
  name     = "testlbtg1"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.aws_vpc_id
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
