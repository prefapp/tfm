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