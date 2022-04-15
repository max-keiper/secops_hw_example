resource "aws_security_group" "rds_SG" {
  name        = "postgres-sandbox-sg"
  description = "Allow Postgres database access on 5432"
  vpc_id      = aws_vpc.Dev_VPC1.id

  ingress {
    description      = "RDS Login access from my PC"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = [var.myIP]
  }
 
  ingress {
    description      = "RDS Login access from my VPC2 Priv server"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = [var.subnet_prefix4]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS-SG"
  }
}

resource "aws_security_group" "vpc2-sg-priv" {
  name        = "EC2-sandbox-sg-priv"
  description = "Allow traffic to VPC2 instances"
  vpc_id      = aws_vpc.Dev_VPC2.id

  ingress {
    description      = "login access to EC2"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.subnet_prefix3]
  }
 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2-SG"
  }
}

# Security Group for public server in VPC2
resource "aws_security_group" "vpc2-sg-pub" {
  name        = "EC2-sandbox-sg-pub"
  description = "Allow traffic to VPC2 instances"
  vpc_id      = aws_vpc.Dev_VPC2.id

  ingress {
    description      = "login access to EC2"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.myIP]
  }
 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2-SG"
  }
}