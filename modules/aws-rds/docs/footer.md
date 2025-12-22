## Additional configuration details

### AWS Secrets Manager

(Only used if `use_secrets_manager = true` and `manage_master_user_password = false`)
- Automatically creates a secret in AWS Secrets Manager containing:
  - username
  - password
  - host
  - port
  - dbname
The ARN of the created secret is exposed via output `secrets_manager_arn`.

If `manage_master_user_password = true`, the RDS instance manages its own secret in Secrets Manager, with rotation options. In that case, output `master_user_secret_arn` will contain the ARN.

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-rds/_examples):

- [PostgreSQL](https://github.com/prefapp/tfm/tree/main/modules/aws-rds/_examples/postgres) - PostgreSQL database with standard configuration
- [MySQL](https://github.com/prefapp/tfm/tree/main/modules/aws-rds/_examples/mysql) - MySQL database with standard configuration
- [SSM Parameter Store](https://github.com/prefapp/tfm/tree/main/modules/aws-rds/_examples/ssm-parameter-store) - RDS instance with SSM Parameter Store integration for credential management
- [Secrets Manager](https://github.com/prefapp/tfm/tree/main/modules/aws-rds/_examples/secret-manager) - RDS instance with AWS Secrets Manager integration for credential management

## Resources

- **Amazon RDS**: [https://docs.aws.amazon.com/rds/](https://docs.aws.amazon.com/rds/)
- **AWS Secrets Manager**: [https://docs.aws.amazon.com/secretsmanager/](https://docs.aws.amazon.com/secretsmanager/)
- **AWS Systems Manager Parameter Store**: [https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
- **RDS Performance Insights**: [https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.html](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.html)
- **Terraform AWS Provider**: [https://registry.terraform.io/providers/hashicorp/aws/latest](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
