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
  bucket = "source-bucket"
  #  testing vars for ruben

  region               = "eu-west-1"
  s3_bucket_versioning = "Enabled"

  s3_replication_destination = {
    account       = "1122334455"
    bucket_arn    = "arn:aws:s3:::destination-bucket"
    storage_class = "STANDARD"
  }

}