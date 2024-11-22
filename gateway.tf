
resource "aws_internet_gateway" "my_project_internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "My Project Internet Gateway"
  }
}


resource "aws_nat_gateway" "my_project_nat_gateway" {

  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.my_project_internet_gateway]

  tags = {
    Name = "My Project NAT Gateway"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "My Project NAT Elastic IP"
  }
}
