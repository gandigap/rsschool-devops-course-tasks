resource "aws_instance" "ec_instance" {
  count         = 1
  ami           = "ami-097c5c21a18dc59ea"
  instance_type = "t3.micro"

  tags = {
    Name = "EC2 instance"
  }
}
