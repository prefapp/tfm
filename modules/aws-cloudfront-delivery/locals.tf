locals {
  # If oac_name is not provided, generate it as "<name_prefix>-s3-oac-<random>" (truncated to 64 chars, AWS limit) to ensure uniqueness
  resolved_oac_name = var.oac_name != null ? var.oac_name : substr("${var.name_prefix}-s3-oac-${random_id.oac_suffix.hex}", 0, 64)

  function_association = merge(
    length(aws_cloudfront_function.custom_response) > 0 ? {
      "viewer-request" = {
        function_arn = aws_cloudfront_function.custom_response[0].arn
      }
    } : {},
  )
}
