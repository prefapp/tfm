locals {
  # If oac_name is not provided, generate it as "<name_prefix>-s3-oac-<random>" (truncated to 64 chars, AWS limit) to ensure uniqueness
  resolved_oac_name = var.oac_name != null ? var.oac_name : substr("${var.name_prefix}-s3-oac-${random_id.oac_suffix.hex}", 0, 64)

  # An existing certificate (acm_certificate_arn) takes precedence over requesting a new one
  create_acm_certificate = var.acm_certificate_arn == null && (var.route53_zone_name != null || var.acm_manual_validation)
  acm_certificate_arn    = var.acm_certificate_arn != null ? var.acm_certificate_arn : (local.create_acm_certificate ? module.acm[0].acm_certificate_arn : null)

  function_association = merge(
    length(aws_cloudfront_function.custom_response) > 0 ? {
      "viewer-request" = {
        function_arn = aws_cloudfront_function.custom_response[0].arn
      }
    } : {},
  )
}
