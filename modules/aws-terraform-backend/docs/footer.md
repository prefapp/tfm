## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-terraform-backend/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/aws-terraform-backend/_examples/basic) - S3 state bucket using S3 lockfiles without a DynamoDB table.
- [DynamoDB locking](https://github.com/prefapp/tfm/tree/main/modules/aws-terraform-backend/_examples/dynamodb-locking) - S3 state bucket with a DynamoDB locks table for legacy locking workflows.

## Remote Resources

- **Amazon S3 state storage**: [https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)
- **DynamoDB state locking**: [https://developer.hashicorp.com/terraform/language/backend/s3](https://developer.hashicorp.com/terraform/language/backend/s3)
- **AWS IAM roles and policies**: [https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)
- **Terraform AWS Provider**: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
