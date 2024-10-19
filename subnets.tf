# Task 2: Networking Resources

# Deploy Public Subnets
resource "aws_subnet" "public_subnet_1" {
  tags = {
    Name = "aws-devops-terraform-public-subnet-1"
  }
  cidr_block              = var.public_subnet_1_cidr
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_2" {
  tags = {
    Name = "aws-devops-terraform-public-subnet-2"
  }
  cidr_block              = var.public_subnet_2_cidr
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true
}

# Deploy Private Subnets
resource "aws_subnet" "private_subnet_1" {
  tags = {
    Name = "aws-devops-terraform-private-subnet-1"
  }
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = "eu-north-1a"
}

resource "aws_subnet" "private_subnet_2" {
  tags = {
    Name = "aws-devops-terraform-private-subnet-2"
  }
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = "eu-north-1b"
}
