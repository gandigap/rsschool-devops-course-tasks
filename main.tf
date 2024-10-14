terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "myrsdevopsbucket"
    key     = "terraform.tfstate"
    region  = "eu-north-1"
    encrypt = true
  }
}

# module "resources" {
#   source           = "./resources"
#   bastion_key_name = var.bastion_key_name
# }
