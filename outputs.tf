output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "k3s_instance_public_ip" {
  value = aws_instance.k3s_instance.public_ip
}

output "k3s_instance_private_ip" {
  value = aws_instance.k3s_instance.private_ip
}
