# Example: Basic S3 Bucket

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "s3" {
  source = "../../"
  bucket = "example-bucket-creation"

}

