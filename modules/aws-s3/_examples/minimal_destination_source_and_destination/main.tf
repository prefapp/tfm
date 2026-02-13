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
  bucket = "origin-and-destination"

  region               = "us-east-1"
  s3_bucket_versioning = "Enabled"
  s3_replication_source = {
    account  = "1122334455"
    role_arn = "arn:aws:iam::1122334455:role/o-a-d-replication"
  }
  s3_replication_destination = {
    account       = "1122334455"
    bucket_arn    = "arn:aws:s3:::o-a-d"
    storage_class = "STANDARD"
  }

}