## Additional configuration details

### YAML Configuration File

The module relies on a YAML file (specified via `data_file`) for all SSO configurations. Key sections include:
- **users**: List of users with name, email, and fullname.
- **groups**: List of groups with name, description, and associated users.
- **permission-sets**: Definitions for permission sets, including custom-policies, managed-policies, and inline-policies.
- **attachments**: Account-specific assignments of permission sets to groups and users.

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-sso/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/aws-sso/_examples/basic) - Basic SSO setup with users, groups, and simple permission sets.
- [Advanced](https://github.com/prefapp/tfm/tree/main/modules/aws-sso/_examples/advanced) - Advanced configuration with mixed policies and multi-account assignments.

## Remote resources

- **AWS IAM Identity Center (SSO)**: [https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)
- **AWS SSO Admin Resources**: [https://docs.aws.amazon.com/singlesignon/latest/developerguide/what-is-scim.html](https://docs.aws.amazon.com/singlesignon/latest/developerguide/what-is-scim.html)
- **Terraform AWS Provider**: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
