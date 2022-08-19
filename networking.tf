# 1. Create a VPC
resource "aws_vpc" "alvin_vpc" {
  cidr_block           = var.vpc_prefix
  enable_dns_hostnames = true

  tags = {
    "Name" = "alvin_vpc"
  }
}

# 2. Create an Internet Gateway
resource "aws_internet_gateway" "alvin_igw" {
  vpc_id = aws_vpc.alvin_vpc.id

  tags = {
    Name = "alvin_igw"
  }
}

# Create Public Subnet 1 A
resource "aws_subnet" "alvin_subnet_1a" {
  vpc_id            = aws_vpc.alvin_vpc.id
  cidr_block        = var.subnet_prefix[0].cidr_block
  availability_zone = var.subnet_prefix[0].availability_zone

  tags = {
    Name = var.subnet_prefix[0].name
  }
}

# Create Public Subnet 1 B
# Associate it with Public Route Table 1
resource "aws_subnet" "alvin_subnet_1b" {
  vpc_id            = aws_vpc.alvin_vpc.id
  cidr_block        = var.subnet_prefix[1].cidr_block
  availability_zone = var.subnet_prefix[1].availability_zone

  tags = {
    Name = var.subnet_prefix[1].name
  }
}

# Create Route Table for Public Subnet 1
resource "aws_route_table" "alvin_rt_pub_1" {
  vpc_id = aws_vpc.alvin_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.alvin_igw.id
  }

  tags = {
    Name = "Alvin Public RT"
  }
}

# Create Private Subnet 2A (App)
resource "aws_subnet" "alvin_subnet_2a" {
  vpc_id                  = aws_vpc.alvin_vpc.id
  cidr_block              = var.subnet_prefix[2].cidr_block
  availability_zone       = var.subnet_prefix[2].availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = var.subnet_prefix[2].name
  }
}

# Create Private Subnet 2B (Web App)
resource "aws_subnet" "alvin_subnet_2b" {
  vpc_id                  = aws_vpc.alvin_vpc.id
  cidr_block              = var.subnet_prefix[3].cidr_block
  availability_zone       = var.subnet_prefix[3].availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = var.subnet_prefix[3].name
  }
}

# Create Private Subnet 3A (DB)
resource "aws_subnet" "alvin_subnet_3a" {
  vpc_id                  = aws_vpc.alvin_vpc.id
  cidr_block              = var.subnet_prefix[4].cidr_block
  availability_zone       = var.subnet_prefix[4].availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = var.subnet_prefix[4].name
  }
}

# Create Private Subnet 3B (DB)
resource "aws_subnet" "alvin_subnet_3b" {
  vpc_id                  = aws_vpc.alvin_vpc.id
  cidr_block              = var.subnet_prefix[5].cidr_block
  availability_zone       = var.subnet_prefix[5].availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = var.subnet_prefix[5].name
  }
}

# Create Private Route Table 2 (App Tier)
# Associate Private Subnet 2A and 3A and Add Route Through NAT Gateway 1
resource "aws_route_table" "alvin_rt_priv_2" {
  vpc_id = aws_vpc.alvin_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.alvin_nat_1.id
  }

  tags = {
    Name = "Alvin Private RT | App Tier"
  }
}

# Create Private Route Table 3 (Database Tier)
# Associate Private Subnet 2B and 3B and Add Route Through NAT Gateway 2
resource "aws_route_table" "alvin_rt_priv_3" {
  vpc_id = aws_vpc.alvin_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.alvin_nat_2.id
  }

  tags = {
    Name = "Alvin Private RT | Database Tier"
  }
}

# Associate Subnets with Route Table
# Associate Subnets 1a and 1b to Public Route Table 1
resource "aws_route_table_association" "alvin_sn_rt_1a" {
  subnet_id      = aws_subnet.alvin_subnet_1a.id
  route_table_id = aws_route_table.alvin_rt_pub_1.id
}

resource "aws_route_table_association" "alvin_sn_rt_1b" {
  subnet_id      = aws_subnet.alvin_subnet_1b.id
  route_table_id = aws_route_table.alvin_rt_pub_1.id
}

# Associate Subnets 2a and 3a to Private Route Table 2 (With Nat Gateway 1)
resource "aws_route_table_association" "alvin_sn_rt_2a" {
  subnet_id      = aws_subnet.alvin_subnet_2a.id
  route_table_id = aws_route_table.alvin_rt_priv_2.id
}

resource "aws_route_table_association" "alvin_sn_rt_3a" {
  subnet_id      = aws_subnet.alvin_subnet_3a.id
  route_table_id = aws_route_table.alvin_rt_priv_2.id
}

# Associate Subnets 2b and 3b to Private Route Table 3 (With Nat Gateway 2)
resource "aws_route_table_association" "alvin_sn_rt_2b" {
  subnet_id      = aws_subnet.alvin_subnet_2b.id
  route_table_id = aws_route_table.alvin_rt_priv_3.id
}

resource "aws_route_table_association" "alvin_sn_rt_3b" {
  subnet_id      = aws_subnet.alvin_subnet_3b.id
  route_table_id = aws_route_table.alvin_rt_priv_3.id
}





