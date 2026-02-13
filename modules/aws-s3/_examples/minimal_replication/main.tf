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
  bucket = "my-origin"

  region               = "us-east-1"
  s3_bucket_versioning = "Enabled"

  s3_replication_destination = {
    account       = "1112222333"
    bucket_arn    = "arn:aws:s3:::my-destination"
    storage_class = "STANDARD"
  }
}
