variable "aws_region" {
  description = "Default AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "bastion_key_name" {
  description = "The name Bastion"
  type        = string
  default     = "your-key-pair-name"
}

