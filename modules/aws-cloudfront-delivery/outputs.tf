output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.cloudfront-delivery.cloudfront_distribution_id
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.cloudfront-delivery.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = module.cloudfront-delivery.cloudfront_distribution_arn
}

output "s3_bucket_delivery_id" {
  description = "The ID of the S3 bucket used for CloudFront delivery"
  value       = module.s3-bucket-delivery.s3_bucket_id
}

output "s3_bucket_delivery_arn" {
  description = "The ARN of the S3 bucket used for CloudFront delivery"
  value       = module.s3-bucket-delivery.s3_bucket_arn
}

output "s3_bucket_delivery_domain_name" {
  description = "The domain name of the S3 bucket used for CloudFront delivery"
  value       = module.s3-bucket-delivery.s3_bucket_bucket_domain_name
}

output "iam_gh_delivery_gh_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions delivery"
  value       = var.gh_delivery_gh_role_enable ? aws_iam_role.gh_delivery_gh_role[0].arn : null
}

output "iam_gh_delivery_gh_role_name" {
  description = "The name of the IAM role for GitHub Actions delivery"
  value       = var.gh_delivery_gh_role_enable ? aws_iam_role.gh_delivery_gh_role[0].name : null
}
