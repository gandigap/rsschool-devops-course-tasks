terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18.0"
    }
  }
  backend "s3" {
    bucket  = "myrsawsnewbucket"
    key     = "terraform.tfstate"
    region  = "eu-north-1"
    encrypt = "true"
  }
}
