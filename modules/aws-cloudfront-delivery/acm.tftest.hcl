mock_provider "aws" {
  mock_data "aws_route53_zone" { defaults = { zone_id = "Z123" } }
  mock_data "aws_caller_identity" { defaults = { account_id = "123456789012" } }
  mock_data "aws_iam_policy_document" { defaults = { json = "{}" } }
  mock_resource "aws_acm_certificate" {
    defaults = {
      arn                       = "arn:aws:acm:us-east-1:123456789012:certificate/new"
      domain_validation_options = [{ domain_name = "cdn.domain.com", resource_record_name = "_x.cdn.domain.com.", resource_record_type = "CNAME", resource_record_value = "_y.acm-validations.aws." }]
    }
  }
  mock_data "aws_cloudfront_cache_policy" { defaults = { id = "c" } }
  mock_data "aws_cloudfront_origin_request_policy" { defaults = { id = "o" } }
  mock_data "aws_cloudfront_response_headers_policy" { defaults = { id = "r" } }
}
mock_provider "random" {}

run "legacy_no_zone_no_cert" {
  command = apply
  variables { cdn_aliases = ["cdn.domain.com"] }
  assert {
    condition     = length(module.acm) == 0 && output.acm_certificate_arn == null
    error_message = "no cert expected"
  }
}

run "legacy_route53" {
  command = apply
  variables {
    cdn_aliases       = ["cdn.domain.com"]
    route53_zone_name = "domain.com"
  }
  assert {
    condition     = length(module.acm) == 1 && length(module.acm[0].validation_route53_record_fqdns) == 1 && length(aws_route53_record.cdn_aliases) == 1
    error_message = "route53 validation records expected"
  }
}

run "manual_validation" {
  command = apply
  variables {
    cdn_aliases            = ["cdn.domain.com"]
    acm_manual_validation  = true
    acm_validation_timeout = "1h30m"
  }
  assert {
    condition     = length(module.acm) == 1 && length(module.acm[0].validation_route53_record_fqdns) == 0 && length(aws_route53_record.cdn_aliases) == 0
    error_message = "cert without route53 records expected"
  }
  assert {
    condition     = output.acm_certificate_arn == "arn:aws:acm:us-east-1:123456789012:certificate/new" && output.acm_certificate_validation_records[0].type == "CNAME"
    error_message = "cert arn / validation records"
  }
}

run "existing_cert_with_zone" {
  command = apply
  variables {
    cdn_aliases         = ["cdn.domain.com"]
    route53_zone_name   = "domain.com"
    acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/existing"
  }
  assert {
    condition     = length(module.acm) == 0 && length(aws_route53_record.cdn_aliases) == 1 && output.acm_certificate_arn == "arn:aws:acm:us-east-1:123456789012:certificate/existing"
    error_message = "existing cert expected"
  }
}

run "reject_manual_with_zone" {
  command = plan
  variables {
    cdn_aliases           = ["cdn.domain.com"]
    route53_zone_name     = "domain.com"
    acm_manual_validation = true
  }
  expect_failures = [var.acm_manual_validation]
}

run "reject_manual_without_aliases" {
  command = plan
  variables { acm_manual_validation = true }
  expect_failures = [var.acm_manual_validation]
}

run "reject_wrong_region_arn" {
  command = plan
  variables { acm_certificate_arn = "arn:aws:acm:eu-west-1:123456789012:certificate/x" }
  expect_failures = [var.acm_certificate_arn]
}

run "reject_arn_and_manual" {
  command = plan
  variables {
    cdn_aliases           = ["cdn.domain.com"]
    acm_certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/x"
    acm_manual_validation = true
  }
  expect_failures = [var.acm_certificate_arn]
}

run "reject_bad_timeout" {
  command = plan
  variables { acm_validation_timeout = "2 hours" }
  expect_failures = [var.acm_validation_timeout]
}
