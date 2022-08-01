terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "aws-stefan-nader"
    #dynamodb_table = "aws-stefan-nader"
    key     = "terraform.tfstate"
    encrypt = false
    region  = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}

# resource "aws_vpc" "test1" {
#   cidr_block         = "10.0.0.0/16"
#   enable_dns_support = true
#   instance_tenancy   = "default"
# }
