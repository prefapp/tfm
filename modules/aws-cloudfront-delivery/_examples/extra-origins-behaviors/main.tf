# Example: SPA from S3 plus two extra origins, each one reached through its own
# ordered cache behavior. Add as many origins and behaviors as you need.

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

  # Each key is an origin ID, referenced below as target_origin_id.
  # CloudFront forwards the full viewer path, prefixed by origin_path:
  # /api/contact reaches the API as /prod/api/contact.
  extra_origins = {
    contact_api = {
      domain_name          = "abc123def4.execute-api.eu-west-1.amazonaws.com"
      origin_path          = "/prod"
      custom_origin_config = {}
    }

    backend_alb = {
      domain_name = "backend.domain.com"
      custom_origin_config = {
        origin_protocol_policy = "https-only"
        origin_read_timeout    = 60
      }
      # Lets the backend reject requests that bypass CloudFront.
      custom_header = {
        "X-Origin-Verify" = "change-me"
      }
    }
  }

  # Evaluated top to bottom before the default (*) behavior.
  ordered_cache_behaviors = [
    {
      path_pattern     = "/api/contact"
      target_origin_id = "contact_api"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]

      # API Gateway rejects requests whose Host is the CloudFront domain.
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
    },
    {
      path_pattern     = "/backend/*"
      target_origin_id = "backend_alb"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]

      cache_policy_name            = "Managed-CachingDisabled"
      origin_request_policy_name   = "Managed-AllViewer"
      response_headers_policy_name = "Managed-SecurityHeadersPolicy"
    },
  ]
}
