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

# Add Egress Rule to allow all outbound traffic
resource "aws_security_group_rule" "egress_any" {
  description       = "Allow any outbound traffic from NAT Instance / Bastion Host"
  security_group_id = aws_security_group.nat_sg.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

# Task 3: k3s Setup

# Deploy Security Group for k3s Server Instance and add all the necessary rules
resource "aws_security_group" "k3s_server_sg" {
  description = "Security group for k3s Server Instance Located in a Private Subnet 1"
  vpc_id      = aws_vpc.main_vpc.id
  name        = "k3s_server_instance_sg"
  tags = {
    Name = "k3s Server Instance Security Group"
  }
}

# Add Ingress Rules to allow ssh inbound traffic to k3s Server
resource "aws_security_group_rule" "ingress_ssh_k3s_server" {
  description       = "Allow inbound SSH traffic to k3s Server instance within VPC"
  security_group_id = aws_security_group.k3s_server_sg.id
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

# Add Ingress Rules to allow inbound traffic to k3s Server from k3s Agents
resource "aws_security_group_rule" "ingress_6443_k3s_server" {
  description       = "Allow inbound traffic to k3s Server instance from k3s Agents"
  security_group_id = aws_security_group.k3s_server_sg.id
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
}

# Allow Flannel VXLAN
resource "aws_security_group_rule" "ingress_flannel_k3s_server" {
  description       = "Allow inbound traffic to k3s Server instance for Flannel VXLAN"
  security_group_id = aws_security_group.k3s_server_sg.id
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
  from_port         = 8472
  to_port           = 8472
  protocol          = "udp"
}

# Allow Kubelet Metrics
resource "aws_security_group_rule" "ingress_metrics_k3s_server" {
  description       = "Allow inbound traffic to k3s Server for Kubelet Metrics"
  security_group_id = aws_security_group.k3s_server_sg.id
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
}

resource "aws_security_group_rule" "egress_any_k3s_server" {
  description       = "Allow any outbound traffic from k3s Server Instance"
  security_group_id = aws_security_group.k3s_server_sg.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

# Deploy Security Group for k3s Agent Instance and add all the necessary rules
resource "aws_security_group" "k3s_agent_sg" {
  description = "Security group for k3s Agent Instance Located in a Private Subnet 2"
  vpc_id      = aws_vpc.main_vpc.id
  name        = "k3s_agent_instance_sg"
  tags = {
    Name = "k3s Agent Instance Security Group"
  }
}

# Add Ingress Rules to allow ssh inbound traffic to k3s Agent
resource "aws_security_group_rule" "ingress_ssh_k3s_agent" {
  description       = "Allow inbound SSH traffic to k3s Agent instance within VPC"
  security_group_id = aws_security_group.k3s_agent_sg.id
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

# Allow Flannel VXLAN
resource "aws_security_group_rule" "ingress_flannel_k3s_agent" {
  description       = "Allow inbound traffic to k3s Agent instance for Flannel VXLAN"
  security_group_id = aws_security_group.k3s_agent_sg.id
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
  from_port         = 8472
  to_port           = 8472
  protocol          = "udp"
}

# Allow Kubelet Metrics
resource "aws_security_group_rule" "ingress_metrics_k3s_agent" {
  description       = "Allow inbound traffic to k3s Agent for Kubelet Metrics"
  security_group_id = aws_security_group.k3s_agent_sg.id
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
}

resource "aws_security_group_rule" "egress_any_k3s_agent" {
  description       = "Allow any outbound traffic from k3s Agent Instance"
  security_group_id = aws_security_group.k3s_agent_sg.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}