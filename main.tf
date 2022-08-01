terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket  = "aws-stefan-nader"
    key     = "terraform.tfstate"
    encrypt = false
    region  = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}
