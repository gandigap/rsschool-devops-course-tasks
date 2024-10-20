# Task 2: Networking Resources

# Create a key pair and load Public Key into environment
resource "aws_key_pair" "ssh_key" {
  key_name   = "bh_key_pair"
  public_key = var.ssh_pk
}
