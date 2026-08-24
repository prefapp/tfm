# aws-cloudfront-delivery

Owns a static-content delivery stack: a private S3 bucket, the CloudFront distribution in front of it, its certificate and DNS records.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**delivery bucket**:
The private S3 bucket holding the static content. It is never public; CloudFront is the only reader, through the OAC.

**OAC**:
Origin Access Control — the CloudFront identity that is allowed to read the delivery bucket. It replaces the legacy origin access identity.
_Avoid_: OAI, origin identity

**alias**:
An alternate domain name on the distribution. Each alias gets a Route 53 record in `route53_zone_name` and is covered by the ACM certificate the module requests.

**custom response function**:
A CloudFront Function attached to the distribution, supplied either inline (`custom_response_script`) or by path (`custom_response_script_path`). Typically used to rewrite SPA routes.

**delivery role**:
The optional GitHub Actions OIDC role (`gh_delivery_gh_role_enable`) allowed to publish into the delivery bucket. `gh_delivery_gh_repositories` is the list of repositories that may assume it.
