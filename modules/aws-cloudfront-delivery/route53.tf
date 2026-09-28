data "aws_route53_zone" "selected" {
  count = var.route53_zone_name != null ? 1 : 0

  name         = var.route53_zone_name
  private_zone = false
}

resource "aws_route53_record" "cdn_aliases" {
  for_each = var.route53_zone_name != null ? toset(var.cdn_aliases) : toset([])

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = module.cloudfront-delivery.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront-delivery.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}
