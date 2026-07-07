## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-parameter-store-replication/_examples):

- [Basic Replication](https://github.com/prefapp/tfm/tree/main/modules/aws-parameter-store-replication/_examples/basic) – Replicate parameters to another AWS account or region
- [EventBridge with KMS](https://github.com/prefapp/tfm/tree/main/modules/aws-parameter-store-replication/_examples/existing_resources) – Event-driven replication with KMS encryption per destination region

## Remote resources

- Terraform: https://www.terraform.io/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest
- AWS Systems Manager Parameter Store: https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html
- aws_ssm_parameter: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter
- AWS Lambda: https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
- aws_lambda_function: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
- AWS EventBridge: https://docs.aws.amazon.com/eventbridge/latest/userguide/what-is-amazon-eventbridge.html
- aws_cloudwatch_event_rule: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
