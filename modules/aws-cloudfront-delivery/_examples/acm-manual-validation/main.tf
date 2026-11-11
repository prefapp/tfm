# Example: ACM certificate validated manually in an external DNS provider

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

# No route53_zone_name: the module requests the certificate and waits until it is
# ISSUED. While `terraform apply` waits, read the validation CNAMEs with
#   aws acm list-certificates --region us-east-1
#   aws acm describe-certificate --region us-east-1 --certificate-arn <arn> \
#     --query 'Certificate.DomainValidationOptions[].ResourceRecord'
# and create them in your DNS provider. Keep them: ACM needs them to renew.
module "cloudfront-delivery" {
  source = "../../"

  name_prefix            = "bucket-prefix-name"
  cdn_aliases            = ["cdn.domain.com", "www.domain.com"]
  acm_manual_validation  = true
  acm_validation_timeout = "2h"
}

output "acm_certificate_validation_records" {
  value = module.cloudfront-delivery.acm_certificate_validation_records
}

output "cloudfront_distribution_domain_name" {
  value = module.cloudfront-delivery.cloudfront_distribution_domain_name
}
