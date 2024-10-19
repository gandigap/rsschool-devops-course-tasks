
# Task 2: Networking Resources

# Deploy Security Group for NAT Instance / Bastion Host
resource "aws_security_group" "nat_sg" {
  description = "Security group for NAT Instance / Bastion Host"
  vpc_id      = aws_vpc.main_vpc.id
  name        = "nat_instance_sg"
  tags = {
    Name = "NAT/Bastion host Security Group"
  }
}

# Add Ingress Rules to allow ssh/icmp inbound traffic
resource "aws_security_group_rule" "ingress_ssh" {
  description       = "Allow inbound SSH traffic to NAT Instance / Bastion Host from specified IP Range"
  security_group_id = aws_security_group.nat_sg.id
  type              = "ingress"
  cidr_blocks       = var.ssh_inbound_ip
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_security_group_rule" "ingress_icmp" {
  description       = "Allow inbound ICMP (Ping) traffic to NAT Instance / Bastion Host"
  security_group_id = aws_security_group.nat_sg.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
}

resource "aws_security_group_rule" "ingress_private_subnet_1" {
  description       = "Allow all private subnet 1 inbound traffic to NAT Instance / Bastion Host"
  security_group_id = aws_security_group.nat_sg.id
  type              = "ingress"
  cidr_blocks       = [var.private_subnet_1_cidr]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "ingress_private_subnet_2" {
  description       = "Allow all private subnet 2 inbound traffic to NAT Instance / Bastion Host"
  security_group_id = aws_security_group.nat_sg.id
  type              = "ingress"
  cidr_blocks       = [var.private_subnet_2_cidr]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

# Add Egress Rulee to allow all outbound traffic
resource "aws_security_group_rule" "egress_any" {
  description       = "Allow any outbound traffic from NAT Instance / Bastion Host"
  security_group_id = aws_security_group.nat_sg.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

# Deploy Security Group for Test Instance
resource "aws_security_group" "test_ec2_sg" {
  description = "Security group for Private Instance"
  vpc_id      = aws_vpc.main_vpc.id
  name        = "test_instance_sg"
  tags = {
    Name = "Private Instance Security Group"
  }
}

# Add Ingress Rules to allow ssh/icmp inbound traffic
resource "aws_security_group_rule" "ingress_ssh_test" {
  description       = "Allow inbound SSH traffic to Private Instance from specified IP Range"
  security_group_id = aws_security_group.test_ec2_sg.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_security_group_rule" "ingress_icmp_test" {
  description       = "Allow inbound ICMP (Ping) traffic to Private Instance"
  security_group_id = aws_security_group.test_ec2_sg.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
}

resource "aws_security_group_rule" "egress_any_test" {
  description       = "Allow any outbound traffic from Private Instance"
  security_group_id = aws_security_group.test_ec2_sg.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}
