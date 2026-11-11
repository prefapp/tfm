# Example: reuse an existing ACM certificate

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.46"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# The certificate must be in us-east-1 and cover every alias. No certificate is
# requested; add route53_zone_name only if the module should create the alias records.
module "cloudfront-delivery" {
  source = "../../"

  name_prefix         = "bucket-prefix-name"
  cdn_aliases         = ["cdn.domain.com"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
}
