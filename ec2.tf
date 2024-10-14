# resource "aws_instance" "bastion" {
#   ami             = "ami-097c5c21a18dc59ea"
#   instance_type   = var.bastion_instance_type
#   subnet_id       = aws_subnet.public_subnet_a.id
#   key_name        = "rs_devops"
#   security_groups = [aws_security_group.bastion_sg.id]

#   tags = {
#     Name = "bastion-host"
#   }
# }
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

# Create a Test EC2 instance in Private nerwork to check all the routing
resource "aws_instance" "test_ec2" {
  ami                    = var.ec2_amazon_linux_ami
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_subnet_2.id
  vpc_security_group_ids = [aws_security_group.test_ec2_sg.id]
  key_name               = aws_key_pair.ssh_key.key_name
  tags = {
    Name = "Test Instance"
  }
}
