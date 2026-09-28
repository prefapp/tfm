module "cloudfront-delivery" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "6.7.1"

  enabled          = true
  aliases          = var.cdn_aliases
  comment          = var.cdn_comment
  http_version     = var.http_version
  is_ipv6_enabled  = var.is_ipv6_enabled
  price_class      = var.price_class
  retain_on_delete = var.retain_on_delete

  origin_access_control = {
    s3_oac = {
      name             = local.resolved_oac_name
      description      = "CloudFront access to S3 bucket delivery ${var.name_prefix}"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = merge({
    s3_delivery = {
      domain_name               = module.s3-bucket-delivery.s3_bucket_bucket_regional_domain_name
      origin_id                 = "s3_delivery"
      origin_access_control_key = "s3_oac"
    }
  }, var.extra_origins)

  default_cache_behavior = {
    target_origin_id       = "s3_delivery"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_name            = "Managed-CachingOptimized"
    origin_request_policy_name   = "Managed-UserAgentRefererHeaders"
    response_headers_policy_name = "Managed-SimpleCORS"

    function_association = local.function_association

    compress = true
  }

  ordered_cache_behavior = var.ordered_cache_behaviors

  custom_error_response = var.custom_error_responses

  viewer_certificate = length(module.acm) > 0 ? {
    acm_certificate_arn      = module.acm[0].acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
    } : {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}

resource "aws_cloudfront_function" "custom_response" {
  count = var.custom_response_script_path != null ? 1 : var.custom_response_script != null ? 1 : 0

  name    = "${var.name_prefix}-custom-response"
  runtime = "cloudfront-js-1.0"
  code    = var.custom_response_script_path != null ? file(var.custom_response_script_path) : var.custom_response_script
}
