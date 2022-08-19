# Security Group for Web app
resource "aws_security_group" "alvin_webapp_sg" {
  description = "Enable HTTP/HTTPS access on Port 8080/443 via ALB and SSH on Port 22 via BH SG"

  name = "alvin_webapp_sg"

  # Which VPC the SG will be created in
  vpc_id = aws_vpc.alvin_vpc.id

  ingress {
    description     = "HTTP Port"
    from_port       = 8080
    protocol        = "tcp"
    to_port         = 8080
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "HTTPS Port"
    from_port       = 443
    protocol        = "tcp"
    to_port         = 443
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "SSH Access"
    from_port       = 22
    protocol        = "tcp"
    to_port         = 22
    security_groups = [aws_security_group.alvin_bh_sg.id]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "outbound from webserver"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    Name        = "alvin_webapp_sg"
    Terraform   = "Yes"
    Environment = "Dev"
  }
}

# Create Security Group for ALB
resource "aws_security_group" "alb_sg" {

  description = "Enable HTTP/HTTPS access on Port 80/443"
  name        = "alvin_alb_sg"
  vpc_id      = aws_vpc.alvin_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS access for ALB"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access for ALB"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound connections from ALB"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    Name        = "alvin_alb_sg"
    Terraform   = "Yes"
    Environment = "Dev"
  }
}

# Security Group for RDS using MariaDB
# Will only allow access from instances having the SG created above
resource "aws_security_group" "mariadb_sg" {

  description = "Enable MySQL/Aurora Access on Port 3306"
  name        = "alvin_mariadb_sg"
  vpc_id      = aws_vpc.alvin_vpc.id

  # Create inbound rule for MySQL - mariadb uses MySQL client

  ingress {
    description     = "MySQL/Aurora Access"
    from_port       = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.alvin_webapp_sg.id]
    to_port         = 3306
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "outbound from MariaDB"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    Name        = "alvin_mariadb_sg"
    Terraform   = "Yes"
    Environment = "Dev"
  }
}

# Create Security Group for Bastion Host/Jump Box

resource "aws_security_group" "alvin_bh_sg" {

  description = "Bastion Host, Enable SSH access on Port 22"
  name        = "alvin_bastion_host_sg"
  vpc_id      = aws_vpc.alvin_vpc.id

  ingress {
    cidr_blocks = [var.ssh_location]
    description = "Bastion Host SG, SSH Access"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  egress {
    cidr_blocks = [var.ssh_location]
    description = "Outbound from Bastion Host"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  tags = {
    Name        = "alvin_bh_SSH_sg"
    Terraform   = "Yes"
    Environment = "Dev"
  }
}

