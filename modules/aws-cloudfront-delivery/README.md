<!-- BEGIN_TF_DOCS -->
# AWS cloudfrom-delivery Terraform Module

## Overview

This module provisions an **AWS CloudFront distribution** to deliver content from an **S3 bucket** created by the same module with the `-delivery` suffix.  
The S3 bucket is generated using the official **terraform-aws-modules/s3-bucket/aws** module.

An **ACM certificate** can also be requested and validated via **domain validation**, allowing the CloudFront distribution to serve content over HTTPS with a custom domain.

The CloudFront distribution is configured to:
- Redirect all HTTP traffic to **HTTPS**
- Use the S3 delivery bucket as its origin
- Attach an ACM certificate for secure TLS communication
- Expose the distribution through a **Route53 hosted zone and DNS record**

This module provides a simple and standardized way to deploy a secure CDN backed by S3, including certificate management and DNS configuration, using Terraform.

## Key Features

- **CloudFront Distribution**: Automatically provisions an AWS CloudFront distribution to serve content globally with low latency.

- **S3 delivery Bucket**: Creates an S3 bucket (with `-delivery` suffix) using the official `terraform-aws-modules/s3-bucket/aws` module as the CloudFront origin.

- **HTTPS Enforcement**: Configures CloudFront to redirect all HTTP requests to HTTPS.

- **ACM Certificate Management**: Optionally requests and validates an ACM certificate using domain validation for secure TLS communication.

- **Route53 DNS Integration**: Creates the required Route53 hosted zone records to expose the CloudFront distribution via a custom domain.

## Basic Usage

### Minimal usage

``` hcl
module "cloudfront" {
  source = "github.com/prefapp/tfm/modules/aws-cloudfront-delivery?ref=aws-cloudfront-delivery-vx.y.z"
  version = "x.y.z"

  name_prefix = "bucket-prefix-name"
  cdn_aliases = ["cdn.domain.com"]

}
```

### Usage with certificate and route53 zones.

``` hcl
module "cloudfront" {
  source = "github.com/prefapp/tfm/modules/aws-cloudfront-delivery?ref=aws-cloudfront-delivery-vx.y.z"
  version = "x.y.z"

  name_prefix = "bucket-prefix-name"
  cdn_aliases = ["cdn.domain.com"]
  route53_zone_name = "domain.com"

}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | 6.1.1 |
| <a name="module_cloudfront-delivery"></a> [cloudfront-delivery](#module\_cloudfront-delivery) | terraform-aws-modules/cloudfront/aws | 5.0.1 |
| <a name="module_s3-bucket-delivery"></a> [s3-bucket-delivery](#module\_s3-bucket-delivery) | terraform-aws-modules/s3-bucket/aws | 5.8.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_function.custom_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_iam_role.gh_delivery_gh_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.gh_delivery_gh_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_route53_record.cdn_aliases](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket_policy.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.gh_delivery_gh_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_versioning_enabled"></a> [bucket\_versioning\_enabled](#input\_bucket\_versioning\_enabled) | Whether to enable versioning on the S3 bucket used for CloudFront delivery. | `bool` | `true` | no |
| <a name="input_cdn_aliases"></a> [cdn\_aliases](#input\_cdn\_aliases) | A list of CNAMEs (alternate domain names) to associate with the CloudFront distribution. | `list(string)` | `[]` | no |
| <a name="input_cdn_comment"></a> [cdn\_comment](#input\_cdn\_comment) | A comment to describe the CloudFront distribution. | `string` | `"CloudFront Distribution for S3 Delivery"` | no |
| <a name="input_custom_response_script"></a> [custom\_response\_script](#input\_custom\_response\_script) | Content of a custom CloudFront Function script for custom responses. | `string` | `null` | no |
| <a name="input_custom_response_script_path"></a> [custom\_response\_script\_path](#input\_custom\_response\_script\_path) | Path to a custom CloudFront Function script for custom responses. | `string` | `null` | no |
| <a name="input_gh_delivery_gh_repositories"></a> [gh\_delivery\_gh\_repositories](#input\_gh\_delivery\_gh\_repositories) | A list of GitHub repositories to grant access to the S3 delivery and CloudFront resources. | `list(string)` | `[]` | no |
| <a name="input_gh_delivery_gh_role_enable"></a> [gh\_delivery\_gh\_role\_enable](#input\_gh\_delivery\_gh\_role\_enable) | Whether to enable the GitHub Actions role for S3 delivery and CloudFront. | `bool` | `false` | no |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | The HTTP version to use for requests to your distribution. | `string` | `"http2and3"` | no |
| <a name="input_is_ipv6_enabled"></a> [is\_ipv6\_enabled](#input\_is\_ipv6\_enabled) | Whether the CloudFront distribution is enabled for IPv6. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to use for naming resources. | `string` | `"cdn-bucket"` | no |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | The price class for the CloudFront distribution. | `string` | `null` | no |
| <a name="input_retain_on_delete"></a> [retain\_on\_delete](#input\_retain\_on\_delete) | Whether to retain the CloudFront distribution when the module is destroyed. | `bool` | `false` | no |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | The name of the Route 53 hosted zone to use in resources that require it. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#output\_cloudfront\_distribution\_arn) | The ARN of the CloudFront distribution |
| <a name="output_cloudfront_distribution_domain_name"></a> [cloudfront\_distribution\_domain\_name](#output\_cloudfront\_distribution\_domain\_name) | The domain name of the CloudFront distribution |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | The ID of the CloudFront distribution |
| <a name="output_cloudfront_origin_access_controls"></a> [cloudfront\_origin\_access\_controls](#output\_cloudfront\_origin\_access\_controls) | The CloudFront Origin Access Controls created |
| <a name="output_cloudfront_origin_access_controls_ids"></a> [cloudfront\_origin\_access\_controls\_ids](#output\_cloudfront\_origin\_access\_controls\_ids) | The IDs of the CloudFront Origin Access Controls created |
| <a name="output_iam_gh_delivery_gh_role_arn"></a> [iam\_gh\_delivery\_gh\_role\_arn](#output\_iam\_gh\_delivery\_gh\_role\_arn) | The ARN of the IAM role for GitHub Actions delivery |
| <a name="output_iam_gh_delivery_gh_role_name"></a> [iam\_gh\_delivery\_gh\_role\_name](#output\_iam\_gh\_delivery\_gh\_role\_name) | The name of the IAM role for GitHub Actions delivery |
| <a name="output_s3_bucket_delivery_arn"></a> [s3\_bucket\_delivery\_arn](#output\_s3\_bucket\_delivery\_arn) | The ARN of the S3 bucket used for CloudFront delivery |
| <a name="output_s3_bucket_delivery_domain_name"></a> [s3\_bucket\_delivery\_domain\_name](#output\_s3\_bucket\_delivery\_domain\_name) | The domain name of the S3 bucket used for CloudFront delivery |
| <a name="output_s3_bucket_delivery_id"></a> [s3\_bucket\_delivery\_id](#output\_s3\_bucket\_delivery\_id) | The ID of the S3 bucket used for CloudFront delivery |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-cloudfront-delivery/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/aws-cloudfront-delivery/_examples/basic) - Basic Cloudfront with s3
- [With acm domain](https://github.com/prefapp/tfm/tree/main/modules/aws-cloudfront-delivery/_examples/withacm) - Basic cloudfront with route53 and ACM certificates

## Resources

- **Cloudfront**: [https://docs.aws.amazon.com/cloudfront/](https://docs.aws.amazon.com/cloudfront/)
- **S3**: [https://docs.aws.amazon.com/s3/](https://docs.aws.amazon.com/s3/)
- **ACM**: [https://docs.aws.amazon.com/acm/](https://docs.aws.amazon.com/acm/)
- **Route53**:  [https://docs.aws.amazon.com/route53/](https://docs.aws.amazon.com/route53/)
- **Terraform AWS Provider**: [https://registry.terraform.io/providers/hashicorp/aws/latest](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->