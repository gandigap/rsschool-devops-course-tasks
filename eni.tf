# Task 2: Networking Resources

# Deploy ENI for NAT Instance (Note: Create A suitable SG for NAT Instance first)
resource "aws_network_interface" "nat_interface" {
  security_groups   = [aws_security_group.nat_sg.id]
  subnet_id         = aws_subnet.public_subnet_1.id
  source_dest_check = false
  description       = "ENI for NAT instance"
}
