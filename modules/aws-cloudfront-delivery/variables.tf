variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "A prefix to use for naming resources."
  type        = string
  default     = "cdn-bucket"
}

variable "route53_zone_name" {
  description = "The name of the Route 53 hosted zone to use in resources that require it."
  type        = string
  nullable    = true
  default     = null
}

variable "cdn_aliases" {
  description = "A list of CNAMEs (alternate domain names) to associate with the CloudFront distribution."
  type        = list(string)
  default     = []
}

variable "cdn_comment" {
  description = "A comment to describe the CloudFront distribution."
  type        = string
  default     = "CloudFront Distribution for S3 Delivery"
}

variable "http_version" {
  description = "The HTTP version to use for requests to your distribution."
  type        = string
  default     = "http2and3"
}

variable "price_class" {
  description = "The price class for the CloudFront distribution."
  type        = string
  nullable    = true
  default     = null
}

variable "retain_on_delete" {
  description = "Whether to retain the CloudFront distribution when the module is destroyed."
  type        = bool
  default     = false
}

variable "is_ipv6_enabled" {
  description = "Whether the CloudFront distribution is enabled for IPv6."
  type        = bool
  nullable    = true
  default     = true
}

variable "custom_response_script" {
  description = "Path to a custom CloudFront Function script for custom responses."
  type        = string
  nullable    = true
  default     = null
}

variable "bucket_versioning_enabled" {
  description = "Whether to enable versioning on the S3 bucket used for CloudFront delivery."
  type        = bool
  default     = true
}

variable "gh_delivery_gh_role_enable" {
  description = "Whether to enable the GitHub Actions role for S3 delivery and CloudFront."
  type        = bool
  default     = false
}

variable "gh_delivery_gh_repositories" {
  description = "A list of GitHub repositories to grant access to the S3 delivery and CloudFront resources."
  type        = list(string)
  default     = []
}
