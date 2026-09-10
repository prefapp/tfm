# Example: Multi-tenant delivery from a single S3 bucket, routed by subdomain
#
# One CloudFront distribution and one S3 bucket serve several tenants. A CloudFront
# Function (viewer-request) rewrites every request URI to the tenant folder that
# matches the left-most label of the Host header (the subdomain). If the subdomain
# is not in the `allowed` map, or the request has no subdomain at all, the request
# falls back to the `default` tenant.
#
# Expected bucket layout (each tenant publishes its build under `<tenant>/current`):
#
#   <name_prefix>-delivery/
#   ├── default/current/index.html   # served for cdn.domain.com and any unknown subdomain
#   └── testing/current/index.html   # served for testing.cdn.domain.com
#
# Routing summary:
#
#   https://cdn.domain.com/            -> /default/current/index.html
#   https://cdn.domain.com/login       -> /default/current/index.html   (SPA route, no extension)
#   https://cdn.domain.com/app.js      -> /default/current/app.js       (asset, has extension)
#   https://testing.cdn.domain.com/    -> /testing/current/index.html
#   https://dummy.cdn.domain.com/      -> /default/current/index.html   ("dummy" is false in allowed)
#   https://other.cdn.domain.com/      -> /default/current/index.html   (not in allowed)
#
# Every tenant hostname must also be a CloudFront alias, so it gets an ACM SAN and a
# Route53 record. You can list them explicitly (as below) or use a wildcard alias
# such as "*.cdn.domain.com".

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "cloudfront-delivery" {
  source = "../../"

  name_prefix       = "bucket-prefix-name"
  cdn_comment       = "Multi-tenant CDN routed by subdomain"
  cdn_aliases       = ["cdn.domain.com", "testing.cdn.domain.com"]
  route53_zone_name = "domain.com"

  # Optional: IAM role assumable from GitHub Actions (OIDC) to publish to the bucket
  # and invalidate the distribution. Repositories created after 2026-07-15 (or opted
  # in) use GitHub's immutable subject claim, so both the organization and the
  # repository must be given as `<name>@<id>`. Legacy repositories keep the
  # `<org>/<repo>` form. See:
  # https://docs.github.com/en/actions/reference/security/oidc#immutable-subject-claims
  gh_delivery_gh_role_enable = true
  gh_delivery_gh_repositories = [
    "my-org@123456/my-frontend-repo@456789",
  ]

  custom_response_script = <<-EOT
    function handler(event) {
        var request = event.request;
        var headers = request.headers || {};
        var host = (headers.host && headers.host.value) ? headers.host.value : "";
        var uri = request.uri || "/";

        // ---- CONFIG: subdomains that should map to /<subdomain>/current ----
        var allowed = { "testing": true, "dummy": false };
        // --------------------------------------------------------------------

        // Normalize leading slash
        if (!uri.startsWith("/")) uri = "/" + uri;

        // Extract left-most label (subdomain)
        var labels = host.split(".");
        var sub = (labels.length > 2) ? labels[0] : ""; // e.g., "testing" from testing.cdn.some.com

        // Build prefix based on allowlist
        var prefix = allowed[sub] ? ("/" + sub + "/current") : "/default/current";

        // Determine if the URI has a file extension
        var last = uri.split("/").pop();
        var hasExtension = last.indexOf(".") !== -1;

        // --- Routing logic ---
        if (uri === "/" || uri === "") {
            // Case: root domain (e.g. https://cdn.some.com)
            request.uri = prefix + "/index.html";
        } else if (!hasExtension) {
            // Case: SPA route (no extension, e.g. /login, /status/id)
            request.uri = prefix + "/index.html";
        } else {
            // Case: asset file (has extension)
            request.uri = prefix + uri;
        }

        return request;
    }
  EOT
}
