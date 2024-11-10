# Task 4: 
# Create a k3s Server instance 
resource "aws_instance" "k3s_server" {
  ami           = var.ec2_amazon_linux_ami
  instance_type = "t3.small"
  key_name      = aws_key_pair.ssh_key.key_name
  tags = {
    Name = "k3s Server Instance"
  }

  network_interface {
    network_interface_id = aws_network_interface.nat_interface.id
    device_index         = 0
    network_card_index   = 0
  }

  user_data = file("k3s_server.sh")
}

