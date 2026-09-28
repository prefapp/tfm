variable "oac_name" {
  validation {
    condition     = var.oac_name == null || (length(var.oac_name) >= 1 && length(var.oac_name) <= 64)
    error_message = "The OAC name (if provided) must be between 1 and 64 characters."
  }
  description = "(Optional) Name for the CloudFront Origin Access Control. If not set, will default to '<name_prefix>-s3-oac-<random>' (truncated to 64 chars) to ensure uniqueness across deployments. Must be unique per AWS account."
  type        = string
  default     = null
}


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

variable "custom_response_script_path" {
  description = "Path to a custom CloudFront Function script for custom responses."
  type        = string
  nullable    = true
  default     = null
}

variable "custom_response_script" {
  description = "Content of a custom CloudFront Function script for custom responses."
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
  description = "A list of GitHub repositories to grant access to the S3 delivery and CloudFront resources. Each entry is used in the OIDC trust policy as `repo:<entry>:*`. Repositories created after 2026-07-15 (or opted in) use GitHub's immutable subject claim, so they must be given as `<org>@<org_id>/<repo>@<repo_id>` (e.g. `my-org@123456/my-repo@456789`); legacy repositories keep the `<org>/<repo>` form. See https://docs.github.com/en/actions/reference/security/oidc#immutable-subject-claims"
  type        = list(string)
  default     = []
}

variable "extra_origins" {
  description = "Additional custom origins (e.g. API Gateway, ALB) for the distribution, keyed by origin ID. The key is the value to use as `target_origin_id` in `ordered_cache_behaviors`. The key `s3_delivery` is reserved for the module's delivery bucket."
  type = map(object({
    domain_name         = string
    origin_path         = optional(string)
    connection_attempts = optional(number)
    connection_timeout  = optional(number)
    custom_origin_config = object({
      http_port                = optional(number, 80)
      https_port               = optional(number, 443)
      origin_protocol_policy   = optional(string, "https-only")
      origin_ssl_protocols     = optional(list(string), ["TLSv1.2"])
      origin_keepalive_timeout = optional(number)
      origin_read_timeout      = optional(number)
    })
    custom_header = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = !contains(keys(var.extra_origins), "s3_delivery")
    error_message = "The origin ID 's3_delivery' is reserved for the module's delivery bucket."
  }

  validation {
    condition = alltrue([
      for o in values(var.extra_origins) : contains(["http-only", "https-only", "match-viewer"], o.custom_origin_config.origin_protocol_policy)
    ])
    error_message = "custom_origin_config.origin_protocol_policy must be one of: http-only, https-only, match-viewer."
  }
}

variable "ordered_cache_behaviors" {
  description = "Additional cache behaviors, evaluated in list order before the default (`*`) behavior; the first item has precedence 0. Each behavior is fully defined here: `target_origin_id` must be `s3_delivery` or a key of `extra_origins`, and exactly one of `cache_policy_name` or `cache_policy_id` is required. Policies accept either a name (managed or custom, e.g. `Managed-CachingDisabled`) or an ID."
  type = list(object({
    path_pattern                 = string
    target_origin_id             = string
    viewer_protocol_policy       = optional(string, "redirect-to-https")
    allowed_methods              = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods               = optional(list(string), ["GET", "HEAD"])
    compress                     = optional(bool, true)
    cache_policy_name            = optional(string)
    cache_policy_id              = optional(string)
    origin_request_policy_name   = optional(string)
    origin_request_policy_id     = optional(string)
    response_headers_policy_name = optional(string)
    response_headers_policy_id   = optional(string)
    function_association = optional(map(object({
      function_arn = string
    })), {})
  }))
  default = []

  validation {
    condition     = alltrue([for b in var.ordered_cache_behaviors : length(trimspace(b.path_pattern)) > 0])
    error_message = "Each ordered cache behavior must have a non-empty path_pattern."
  }

  validation {
    condition     = length(distinct([for b in var.ordered_cache_behaviors : b.path_pattern])) == length(var.ordered_cache_behaviors)
    error_message = "Each ordered cache behavior must have a unique path_pattern."
  }

  validation {
    condition = alltrue([
      for b in var.ordered_cache_behaviors : contains(concat(["s3_delivery"], keys(var.extra_origins)), b.target_origin_id)
    ])
    error_message = "Each ordered cache behavior target_origin_id must be 's3_delivery' or a key of extra_origins."
  }

  validation {
    condition = alltrue([
      for b in var.ordered_cache_behaviors : contains(["allow-all", "https-only", "redirect-to-https"], b.viewer_protocol_policy)
    ])
    error_message = "viewer_protocol_policy must be one of: allow-all, https-only, redirect-to-https."
  }

  validation {
    condition = alltrue([
      for b in var.ordered_cache_behaviors : (b.cache_policy_name == null) != (b.cache_policy_id == null)
    ])
    error_message = "Each ordered cache behavior requires exactly one of cache_policy_name or cache_policy_id."
  }

  validation {
    condition = alltrue(flatten([
      for b in var.ordered_cache_behaviors : [for k in keys(b.function_association) : contains(["viewer-request", "viewer-response"], k)]
    ]))
    error_message = "function_association keys must be 'viewer-request' or 'viewer-response'."
  }
}

variable "custom_error_responses" {
  description = "Custom error pages for the distribution. Each item maps an origin `error_code` to an optional `response_page_path` (served through the matching cache behavior) and `response_code` returned to the viewer; both must be set together. `error_caching_min_ttl` sets how long CloudFront caches the error. Applies to every behavior, including those targeting `extra_origins`."
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.custom_error_responses : contains([400, 403, 404, 405, 414, 416, 500, 501, 502, 503, 504], r.error_code)
    ])
    error_message = "error_code must be one of: 400, 403, 404, 405, 414, 416, 500, 501, 502, 503, 504."
  }

  validation {
    condition     = length(distinct([for r in var.custom_error_responses : r.error_code])) == length(var.custom_error_responses)
    error_message = "Each custom error response must have a unique error_code."
  }

  validation {
    condition     = alltrue([for r in var.custom_error_responses : (r.response_code == null) == (r.response_page_path == null)])
    error_message = "response_code and response_page_path must be set together."
  }

  validation {
    condition     = alltrue([for r in var.custom_error_responses : r.response_page_path == null || startswith(coalesce(r.response_page_path, "/"), "/")])
    error_message = "response_page_path must start with '/'."
  }

  validation {
    condition     = alltrue([for r in var.custom_error_responses : r.error_caching_min_ttl == null || coalesce(r.error_caching_min_ttl, 0) >= 0])
    error_message = "error_caching_min_ttl must be greater than or equal to 0."
  }
}
