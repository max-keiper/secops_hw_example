resource "aws_vpc" "Dev_VPC1" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "sandbox-Dev-VPC-rds"
    ENV  = "Dev"
  }
}

resource "aws_subnet" "subnet-1-pri" {
    vpc_id = aws_vpc.Dev_VPC1.id
    cidr_block = var.subnet_prefix1
    availability_zone = "us-east-1a"

    tags = {
        Name = "Dev-VPC1-subnet1"
    }
}

resource "aws_subnet" "subnet-2-pri" {
    vpc_id = aws_vpc.Dev_VPC1.id
    cidr_block = var.subnet_prefix2
    availability_zone = "us-east-1b"

    tags = {
        Name = "Dev-VPC1-subnet2"
    }
}

resource "aws_route_table" "private-RT-1" {
  vpc_id = aws_vpc.Dev_VPC1.id

  route {
    cidr_block = "10.20.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.VPC1-VPC2-sanbox-peering.id
  }

  tags = {
    Name = "private-RT-1"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.subnet-1-pri.id
  route_table_id = aws_route_table.private-RT-1.id
}

resource "aws_route_table_association" "b" {
  subnet_id = aws_subnet.subnet-2-pri.id
  route_table_id = aws_route_table.private-RT-1.id
}

resource "aws_vpc" "Dev_VPC2" {
    cidr_block = "10.20.0.0/16"
    tags = {
        Name = "sandbox-Dev-VPC2"
        ENV = "Dev"
    }
}

resource "aws_internet_gateway" "Dev-gw-2" {
  vpc_id = aws_vpc.Dev_VPC2.id

  tags = {
    Name = "Dev-gw-2"
  }
}

resource "aws_subnet" "subnet-3-pub" {
    vpc_id = aws_vpc.Dev_VPC2.id
    cidr_block = var.subnet_prefix3
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "Dev-VPC2-subnet3-pub"
    }
}

resource "aws_route_table" "public-RT-2" {
  vpc_id = aws_vpc.Dev_VPC2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Dev-gw-2.id
  }

  tags = {
    Name = "private-RT-2"
  }
}

resource "aws_route_table_association" "c" {
  subnet_id = aws_subnet.subnet-3-pub.id
  route_table_id = aws_route_table.public-RT-2.id
}

resource "aws_subnet" "subnet-4-pri" {
    vpc_id = aws_vpc.Dev_VPC2.id
    cidr_block = var.subnet_prefix4
    availability_zone = "us-east-1a"

    tags = {
        Name = "Dev-VPC2-subnet4-pri"
    }
}

resource "aws_eip" "nat-eip" {
  vpc = true
}

resource "aws_nat_gateway" "VPC2-NAT-gw-subnet-3-pub" {
  allocation_id = aws_eip.nat-eip.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.subnet-3-pub.id
}

resource "aws_route_table" "private-RT-3" {
  vpc_id = aws_vpc.Dev_VPC2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.VPC2-NAT-gw-subnet-3-pub.id
  }

  route {
    cidr_block = "10.10.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.VPC1-VPC2-sanbox-peering.id
  }

  tags = {
    Name = "private-RT-3"
  }
}

resource "aws_route_table_association" "d" {
  subnet_id = aws_subnet.subnet-4-pri.id
  route_table_id = aws_route_table.private-RT-3.id
}

resource "aws_db_subnet_group" "postgres-subnet-group" {
    name = "postgres database subnets"
    subnet_ids = [aws_subnet.subnet-1-pri.id, aws_subnet.subnet-2-pri.id]
    description = "subnet group for sandbox postgres RDS"

    tags = {
        Name = "Postgres-subnet-group"
    }
}

resource "aws_vpc_peering_connection" "VPC1-VPC2-sanbox-peering" {
  peer_owner_id = var.peer-owner-id
  peer_vpc_id   = aws_vpc.Dev_VPC1.id
  vpc_id        = aws_vpc.Dev_VPC2.id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between RDS VPC and VPC2"
  }
}

resource "aws_route" "vpc1-route" {
  route_table_id = aws_vpc.Dev_VPC1.main_route_table_id
  destination_cidr_block = aws_vpc.Dev_VPC2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.VPC1-VPC2-sanbox-peering.id
}

resource "aws_route" "VPC2-route" {
  route_table_id = aws_vpc.Dev_VPC2.main_route_table_id
  destination_cidr_block = aws_vpc.Dev_VPC1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.VPC1-VPC2-sanbox-peering.id
}