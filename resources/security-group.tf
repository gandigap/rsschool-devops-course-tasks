# Security Group for Public Subnets
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id

  # Allow inbound traffic on port 80 (HTTP) and port 443 (HTTPS)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public Security Group"
  }
}

# Security Group for Private Subnets
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id

  # Allow inbound traffic from the public security group (for example, for SSH)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private Security Group"
  }
}
