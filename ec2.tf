# Task 2: Networking Resources

# Deploy EC2 Bastion Host / NAT Instance
resource "aws_instance" "nat_instance" {
  ami           = var.ec2_amazon_linux_ami
  instance_type = "t3.micro"
  key_name      = aws_key_pair.ssh_key.key_name
  tags = {
    Name = "Bastion Host / NAT Instance for Kubernetes Infrastructure"
  }
  network_interface {
    network_interface_id = aws_network_interface.nat_interface.id
    device_index         = 0
    network_card_index   = 0
  }
  user_data                   = <<-EOL
                #! /bin/bash
                sudo yum install iptables-services -y
                sudo systemctl enable iptables
                sudo systemctl start iptables
                sudo sysctl -w net.ipv4.ip_forward=1
                sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
                sudo /sbin/iptables -F FORWARD
              EOL
  user_data_replace_on_change = true
}

# Task 3: k3s Setup

# Create a k3s Server instance in Private subnet #1
resource "aws_instance" "k3s_server" {
  ami                    = var.ec2_amazon_linux_ami
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.k3s_server_sg.id]
  key_name               = aws_key_pair.ssh_key.key_name
  tags = {
    Name = "k3s Server Instance"
  }

  user_data = file("k3s_server.sh") # Загружаем содержимое файла
}

# Create a k3s Agent instance in Private subnet #2
resource "aws_instance" "k3s_agent" {
  ami                    = var.ec2_amazon_linux_ami
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_subnet_2.id
  vpc_security_group_ids = [aws_security_group.k3s_agent_sg.id]
  key_name               = aws_key_pair.ssh_key.key_name
  tags = {
    Name = "K3s Agent Instance"

  }
}
