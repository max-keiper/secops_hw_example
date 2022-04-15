resource "aws_network_interface" "jump-host-nic" {
  subnet_id       = aws_subnet.subnet-3-pub.id
  private_ips     = ["10.20.1.50"]
  security_groups = [aws_security_group.vpc2-sg-pub.id]
}

resource "aws_eip" "jump-host-eip" {
    vpc = true
    network_interface = aws_network_interface.jump-host-nic.id
    associate_with_private_ip = "10.20.1.50"
    depends_on = [aws_internet_gateway.Dev-gw-2]
}

resource "aws_instance" "jump-host" {
    ami  = "ami-074c1f40d02907260"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "ue1-access-key"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.jump-host-nic.id
    }

    tags = {
        Name = "pubserver"
        Purpose = "sandboxTask"
    }
}

resource "aws_instance" "Privserver" {
    ami  = "ami-074c1f40d02907260"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "ue1-access-key"
    subnet_id     = aws_subnet.subnet-4-pri.id

    tags = {
        Name = "privserver"
        Purpose = "sandboxTask"
    }
}

resource "aws_db_instance" "sandbox-db-sandbox" {
  identifier             = var.database-instance-identifier
  instance_class         = var.database-instance-class
  engine                 = "postgres"
  engine_version         = "13.4"
  storage_type           = "gp2"
  allocated_storage      = 20
  db_name                = "sandbox_rds"
  db_subnet_group_name   = aws_db_subnet_group.postgres-subnet-group.name
  availability_zone      = "us-east-1a"
  skip_final_snapshot    = true
  storage_encrypted      = true
  username               = "postgres"
  password               = "ChangeThisPasswordN0w!"
  vpc_security_group_ids = [aws_security_group.rds_SG.id]
  port                   = "5432"
  multi_az               = var.multi-az-deployment
  apply_immediately      = true
}