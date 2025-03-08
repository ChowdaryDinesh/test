
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
