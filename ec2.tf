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


