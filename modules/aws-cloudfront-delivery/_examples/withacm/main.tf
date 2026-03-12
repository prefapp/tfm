# Example: Basic CloudFront Distribution with S3 Origin

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "cloudfront-delivery" {
  source = "../../"

  name_prefix       = "bucket-prefix-name"
  cdn_aliases       = ["cdn.domain.com"]
  route53_zone_name = "domain.com"
}