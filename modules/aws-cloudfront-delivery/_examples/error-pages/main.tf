# Example: custom error pages served from the delivery bucket

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
  cdn_aliases       = ["www.domain.com"]
  route53_zone_name = "domain.com"

  # The pages must exist in the delivery bucket (e.g. errors/404.html).
  # The bucket is private, so a missing object returns 403 from S3.
  custom_error_responses = [
    {
      error_code         = 403
      response_code      = 404
      response_page_path = "/errors/404.html"
    },
    {
      error_code         = 404
      response_code      = 404
      response_page_path = "/errors/404.html"
    },
    {
      error_code            = 503
      response_code         = 503
      response_page_path    = "/errors/503.html"
      error_caching_min_ttl = 10
    },
  ]
}
