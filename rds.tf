# Create Database Subnet Group
# terraform aws db subnet group (Google)
resource "aws_db_subnet_group" "alvin_subnet_group_1" {
  name        = "alvin db subnets"
  subnet_ids  = [aws_subnet.alvin_subnet_3a.id, aws_subnet.alvin_subnet_3b.id]
  description = "Subnet for Database instance"

  tags = {
    Name = "Alvin Database Subnets"
  }
}

# Create Database Instance
resource "aws_db_instance" "alvin_mariadb" {
  allocated_storage      = 20
  db_name                = "alvindb"
  identifier             = "alvin-wordpress-db"
  engine                 = "mariadb"
  engine_version         = "10.6.8"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mariadb10.6"
  db_subnet_group_name   = aws_db_subnet_group.alvin_subnet_group_1.name
  vpc_security_group_ids = [aws_security_group.mariadb_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}

