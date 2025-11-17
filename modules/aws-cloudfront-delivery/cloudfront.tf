module "cloudfront-delivery" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "5.0.1"

  enabled          = true
  aliases          = var.cdn_aliases
  comment          = var.cdn_comment
  http_version     = var.http_version
  is_ipv6_enabled  = var.is_ipv6_enabled
  price_class      = var.price_class
  retain_on_delete = var.retain_on_delete

  origin = {
    s3_delivery = {
      domain_name = module.s3-bucket-delivery.s3_bucket_bucket_regional_domain_name
      origin_id   = "s3_delivery"
    }
  }

  default_cache_behavior = {
    path_pattern           = "*"
    target_origin_id       = "s3_delivery"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    use_forwarded_values = false

    cache_policy_name            = "Managed-CachingOptimized"
    origin_request_policy_name   = "Managed-UserAgentRefererHeaders"
    response_headers_policy_name = "Managed-SimpleCORS"

    function_association = local.function_association
  }

  viewer_certificate = length(module.acm) > 0 ? {
    acm_certificate_arn      = module.acm[0].acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
    } : {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }

}

locals {
  function_association = merge(
    length(aws_cloudfront_function.custom_response) > 0 ? {
      "viewer-request" = {
        function_arn = aws_cloudfront_function.custom_response[0].arn
      }
    } : {},
  )
}

resource "aws_cloudfront_function" "custom_response" {
  count = var.custom_response_script != null ? 1 : 0

  name    = "${var.name_prefix}-custom-response"
  runtime = "cloudfront-js-1.0"
  code    = file(var.custom_response_script)
}
