# Task 2: Networking Resources

# Deploy IGW for Public Subnet
resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "aws-devops-terraform-igw"
  }
  vpc_id = aws_vpc.main_vpc.id
}