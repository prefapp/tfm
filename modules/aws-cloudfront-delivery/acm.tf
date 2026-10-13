module "acm" {
  count = local.create_acm_certificate ? 1 : 0

  source  = "terraform-aws-modules/acm/aws"
  version = "6.1.1"
  region  = "us-east-1"

  domain_name               = var.cdn_aliases[0]
  subject_alternative_names = slice(var.cdn_aliases, 1, length(var.cdn_aliases))
  validation_method         = "DNS"
  validate_certificate      = true
  validation_timeout        = var.acm_validation_timeout

  # Without a Route 53 zone the validation CNAMEs are created by the caller; the
  # module still waits until the certificate is ISSUED before CloudFront uses it.
  create_route53_records = var.route53_zone_name != null
  zone_id                = var.route53_zone_name != null ? data.aws_route53_zone.selected[0].zone_id : ""

  tags = merge(
    var.tags,
    {
      Name      = format("%s-acm", var.name_prefix)
      terraform = true
    }
  )
}
