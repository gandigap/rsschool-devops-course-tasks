# # Task 4: 
# # Create a k3s Server instance 
# resource "aws_instance" "k3s_server" {
#   ami           = var.ec2_amazon_linux_ami
#   instance_type = "t3.small"
#   key_name      = aws_key_pair.ssh_key.key_name
#   tags = {
#     Name = "k3s Server Instance"
#   }

#   network_interface {
#     network_interface_id = aws_network_interface.nat_interface.id
#     device_index         = 0
#     network_card_index   = 0
#   }

#   user_data = file("k3s_server.sh")
# }

# resource "aws_instance" "public_instances" {
#   count = length(var.public_subnet_cidrs)

#   ami           = var.ec2_amazon_linux_ami
#   instance_type = var.ec2_instance_type
#   key_name      = aws_key_pair.ssh_key.key_name

#   subnet_id                   = element(aws_subnet.public_subnet[*].id, count.index)
#   vpc_security_group_ids      = [aws_security_group.public_instance.id]
#   associate_public_ip_address = true

#   tags = {
#     Name        = "Public Instance  ${count.index + 1}"
#     Environment = "Development"
#   }
# }

# resource "aws_instance" "private_instances" {
#   count = length(var.private_subnet_cidrs)

#   ami           = var.ec2_amazon_linux_ami
#   instance_type = var.ec2_instance_type
#   key_name      = aws_key_pair.ssh_key.key_name

#   subnet_id = element(aws_subnet.private_subnet[*].id, count.index)
#   vpc_security_group_ids = [
#     aws_security_group.private_instance.id
#   ]
#   associate_public_ip_address = false

#   tags = {
#     Name        = "Private Instance  ${count.index + 1}"
#     Environment = "Development"
#   }
# }

# resource "aws_instance" "bastion_host" {
#   ami           = var.ec2_amazon_linux_ami
#   instance_type = var.ec2_instance_type
#   subnet_id     = aws_subnet.public_subnet[0].id
#   vpc_security_group_ids = [
#     aws_security_group.bastion.id
#   ]
#   key_name = aws_key_pair.ssh_key.key_name
#   tags = {
#     Name = "Bastion Host"
#   }
# }

resource "aws_instance" "k3s_instance" {
  ami                         = var.ec2_amazon_linux_ami
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.public_subnet[0].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.k3s.id]

  tags = {
    Name = "K3s instance"
  }

  user_data = file("k3s_server.sh")
}


