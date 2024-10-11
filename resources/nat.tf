# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name    = "Elastic IP for the NAT Gateway"
    Project = "Rs-devops"
  }
}

# Create the NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "NAT-Gateway"
  }
}

# Update the route for private subnets
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.aws_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}
