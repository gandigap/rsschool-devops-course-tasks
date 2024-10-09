resource "aws_instance" "bastion" {
  ami             = "ami-097c5c21a18dc59ea"
  instance_type   = var.bastion_instance_type
  subnet_id       = aws_subnet.public_subnet_a.id
  key_name        = "rs_devops"
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion-host"
  }
}
