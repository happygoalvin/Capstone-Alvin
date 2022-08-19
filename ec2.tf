# Create Amazon Linux 2 Instance on EC2
# Bastion Host Instance
resource "aws_instance" "alvin_al2_bh" {
  ami                         = var.ec2_ami
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.alvin_bh_sg.id]
  subnet_id                   = aws_subnet.alvin_subnet_1a.id
  associate_public_ip_address = true
  key_name                    = var.my-keypair

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name                       = "Alvin Amazon Linux 2 | Bastion Host"
    Terraform                  = "Yes"
    Environment                = "Dev"
    "Inspector Resource Group" = "Alvin"
  }
}

# Wordpress instance
resource "aws_instance" "alvin_al2_wp" {
  ami                    = var.ec2_ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.alvin_webapp_sg.id]
  subnet_id              = aws_subnet.alvin_subnet_2a.id
  key_name               = var.my-keypair

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name                       = "Alvin Amazon Linux 2 | Wordpress Server"
    Terraform                  = "Yes"
    Environment                = "Dev"
    "Inspector Resource Group" = "Alvin"
  }
}

