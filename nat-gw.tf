# Allocate Elastic IP Address 1 (EIP 1) for AZ A
resource "aws_eip" "alvin_eip_1" {
  vpc = true

  tags = {
    Name = "Alvin EIP 1 | ap-southeast-2a"
  }
}

# Allocate Elastic IP Address 2 (EIP 2) for AZ B
resource "aws_eip" "alvin_eip_2" {
  vpc = true

  tags = {
    Name = "Alvin EIP 2 | ap-southeast-2b"
  }
}

#Create Nat Gateway 1 in Public Subnet 1a for AZ A
resource "aws_nat_gateway" "alvin_nat_1" {
  allocation_id = aws_eip.alvin_eip_1.id
  subnet_id     = aws_subnet.alvin_subnet_1a.id

  tags = {
    Name = "Alvin NAT Gateway 1 | ap-southeast-2a"
  }
}

# Create NAT Gateway 2 in Public Subnet 1b for AZ B
resource "aws_nat_gateway" "alvin_nat_2" {
  allocation_id = aws_eip.alvin_eip_2.id
  subnet_id     = aws_subnet.alvin_subnet_1b.id

  tags = {
    Name = "Alvin NAT Gateway 2 | ap-southeast-2b"
  }
}





