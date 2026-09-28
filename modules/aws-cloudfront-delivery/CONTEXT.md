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

**extra origin**:
A caller-defined custom origin (`extra_origins`), such as an API Gateway endpoint, added next to the delivery bucket. Its map key is its origin ID; `s3_delivery` is reserved for the delivery bucket.

**ordered cache behavior**:
A caller-defined path-pattern rule (`ordered_cache_behaviors`) that routes matching requests to the delivery bucket or an extra origin, with its own cache and request policies. Evaluated in list order before the default `*` behavior.

**custom error response**:
A distribution-wide rule (`custom_error_responses`) that replaces an origin error code with a page from the distribution and/or a different status code. It is not scoped to a cache behavior.
