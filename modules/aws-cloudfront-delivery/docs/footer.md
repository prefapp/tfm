
## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-cloudfront-delivery/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/aws-cloudfront-delivery/_examples/basic) - Basic Cloudfront with s3
- [With acm domain](https://github.com/prefapp/tfm/tree/main/modules/aws-cloudfront-delivery/_examples/withacm) - Basic cloudfront with route53 and ACM certificates
- [Multi-tenant by subdomain](https://github.com/prefapp/tfm/tree/main/modules/aws-cloudfront-delivery/_examples/multitenant-subdomain-script) - Several tenants in one bucket, routed by subdomain with a custom CloudFront Function and a GitHub Actions delivery role (immutable subject claim)

## Resources

- **Cloudfront**: [https://docs.aws.amazon.com/cloudfront/](https://docs.aws.amazon.com/cloudfront/)
- **S3**: [https://docs.aws.amazon.com/s3/](https://docs.aws.amazon.com/s3/)
- **ACM**: [https://docs.aws.amazon.com/acm/](https://docs.aws.amazon.com/acm/)
- **Route53**:  [https://docs.aws.amazon.com/route53/](https://docs.aws.amazon.com/route53/)
- **Terraform AWS Provider**: [https://registry.terraform.io/providers/hashicorp/aws/latest](https://registry.terraform.io/providers/hashicorp/aws/latest)


## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)