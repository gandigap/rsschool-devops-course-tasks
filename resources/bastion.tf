resource "aws_instance" "bastion" {
  ami           = "ami-097c5c21a18dc59ea"
  instance_type = var.bastion_instance_type
  subnet_id     = aws_subnet.public_subnet_a.id
  key_name      = "rs_devops"

  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_instance" "ec2_private_a" {
  ami           = "ami-097c5c21a18dc59ea"
  instance_type = var.bastion_instance_type

  subnet_id              = aws_subnet.private_subnet_a.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  key_name = "rs_devops"

  tags = {
    Name    = "EC2 in Private Subnet #a"
    Project = "Task 2"
  }
}

resource "aws_instance" "ec2_private_b" {
  ami           = "ami-097c5c21a18dc59ea"
  instance_type = var.bastion_instance_type

  subnet_id              = aws_subnet.private_subnet_b.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  key_name = "rs_devops"

  tags = {
    Name    = "EC2 in Private Subnet #b"
    Project = "Task 2"
  }
}

resource "aws_key_pair" "aws_auth" {
  key_name   = var.ssh_pubkey_name
  public_key = file(var.ssh_pubkey_path)
}
