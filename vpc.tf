# Deploy VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "aws-devops-terraform-vpc"
  }
}




# # Create VPC
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = "aws-vpc-main"
#   }
# }

# # Create Internet Gateway
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "aws-internet-gateway-igw"
#   }
# }

# # Create Public Subnets
# resource "aws_subnet" "public_subnet_a" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.1.0/24"
#   availability_zone = "eu-north-1a"

#   tags = {
#     Name = "aws-public-subnet-a"
#   }
# }

# resource "aws_subnet" "public_subnet_b" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone = "eu-north-1b"

#   tags = {
#     Name = "aws-public-subnet-b"
#   }
# }

# # Create Private Subnets
# resource "aws_subnet" "private_subnet_a" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.3.0/24"
#   availability_zone = "eu-north-1a"

#   tags = {
#     Name = "aws-private-subnet-a"
#   }
# }

# resource "aws_subnet" "private_subnet_b" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.4.0/24"
#   availability_zone = "eu-north-1b"

#   tags = {
#     Name = "aws-private-subnet-b"
#   }
# }

# # Create Route Table for Public Subnets
# resource "aws_route_table" "aws_public_route_table" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }

#   tags = {
#     Name = "aws-public-route-table"
#   }
# }

# # Associate Public Subnets with Route Table
# resource "aws_route_table_association" "public_subnet_a_association" {
#   subnet_id      = aws_subnet.public_subnet_a.id
#   route_table_id = aws_route_table.aws_public_route_table.id
# }

# resource "aws_route_table_association" "public_subnet_b_association" {
#   subnet_id      = aws_subnet.public_subnet_b.id
#   route_table_id = aws_route_table.aws_public_route_table.id
# }

# # Create Route Table for Private Subnets
# resource "aws_route_table" "aws_private_route_table" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "aws-private-route-table"
#   }
# }

# # Associate Private Subnets with Route Table
# resource "aws_route_table_association" "private_subnet_a_association" {
#   subnet_id      = aws_subnet.private_subnet_a.id
#   route_table_id = aws_route_table.aws_private_route_table.id
# }

# resource "aws_route_table_association" "private_subnet_b_association" {
#   subnet_id      = aws_subnet.private_subnet_b.id
#   route_table_id = aws_route_table.aws_private_route_table.id
# }
