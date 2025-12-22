<!-- BEGIN_TF_DOCS -->
# **AWS RDS Terraform Module**

## Overview

This Terraform module provisions and manages AWS RDS (Relational Database Service) instances with comprehensive configuration options and security best practices. It simplifies the deployment of production-ready database instances by handling associated resources such as security groups, subnet groups, and credential management.

The module supports multiple database engines including PostgreSQL, MySQL, and MariaDB, providing flexibility for different application requirements. It offers seamless integration with AWS Systems Manager Parameter Store and AWS Secrets Manager for secure credential storage and management. Additionally, it supports native RDS-managed password rotation through Secrets Manager for enhanced security compliance.

Built with operational excellence in mind, the module enables customization of networking, backup strategies, performance monitoring, and security configurations, making it suitable for development, staging, and production environments.

## Key Features

- **Multi-Engine Support**: Compatible with PostgreSQL, MySQL, MariaDB, and other RDS-supported database engines with configurable versions and parameter groups.
- **Flexible Credential Management**: Choose between AWS Systems Manager Parameter Store, AWS Secrets Manager, or native RDS-managed Secrets Manager with automatic password rotation.
- **Advanced Networking Configuration**: Deploy instances using VPC/subnet IDs or tags, with customizable security groups and additional security rules for fine-grained access control.
- **High Availability & Backup**: Configurable Multi-AZ deployments, automated backups with retention policies, and customizable maintenance windows for production workloads.
- **Performance Monitoring**: Built-in support for Performance Insights with configurable retention periods to monitor and optimize database performance.
- **Storage Flexibility**: Supports multiple storage types (gp2, gp3, io1, standard) with autoscaling capabilities and provisioned IOPS for demanding workloads.

## Basic Usage

### PostgreSQL Database

```hcl
module "rds_postgres" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-rds"

  region        = "eu-west-1"
  environment   = "dev"
  db_identifier = "main"

  vpc_tag_name    = "k8s-org-vpc"
  subnet_tag_name = "private"

  engine         = "postgres"
  engine_version = "17.2"
  family         = "postgres17"
  db_port        = 5432
  db_name        = "main"
  db_username    = "postgres"

  instance_class    = "db.t3.micro"
  storage_type      = "gp3"
  allocated_storage = 50

  manage_master_user_password = false
}
```

### MySQL Database

```hcl
module "rds_mysql" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-rds"

  region        = "eu-west-1"
  environment   = "pro"
  db_identifier = "myapp"

  vpc_tag_name    = "main-vpc"
  subnet_tag_name = "rds"

  engine         = "mysql"
  engine_version = "8.0"
  family         = "mysql8.0"
  db_port        = 3306
  db_name        = "production"
  db_username    = "admin"

  instance_class    = "db.t3.small"
  storage_type      = "gp3"
  allocated_storage = 100

  manage_master_user_password = false
}
```

## File Structure

The module is organized with the following directory and file structure:

```
aws-rds/
├── main.tf                   # Core RDS instance and DB subnet group resources
├── variables.tf              # Input variable definitions
├── outputs.tf                # Output value definitions
├── locals.tf                 # Local value computations and logic
├── _examples/                # Usage examples for different scenarios
│   ├── mysql/                # MySQL database example
│   ├── postgres/             # PostgreSQL database example
│   ├── secret-manager/       # Secrets Manager integration
│   └── ssm-parameter-store/  # SSM Parameter Store integration
└── docs/                     # Documentation files
    ├── header.md             # This file - module overview and usage
    └── footer.md             # Additional resources and support
```

**Key Files**:

- **main.tf**: Defines the RDS instance, security groups, subnet groups, and SSM/Secrets Manager resources.
- **variables.tf**: Comprehensive input variables for networking, database configuration, credential management, and security settings.
- **outputs.tf**: Exports instance endpoints, credential references, and resource identifiers for downstream modules.
- **locals.tf**: Contains conditional logic for credential management (SSM vs Secrets Manager vs RDS-managed) and resource naming conventions.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_secretsmanager_secret.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.db_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.db_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.db_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.db_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.db_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.db_username](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_security_group.by_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_security_group.by_tag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_subnets.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.by_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Allocated storage in GB | `number` | `50` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Whether to allow major version upgrades | `bool` | `false` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Whether to apply changes immediately | `bool` | `false` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of days to retain backups | `number` | `3` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Preferred backup window | `string` | `null` | no |
| <a name="input_db_endpoint_ssm_name"></a> [db\_endpoint\_ssm\_name](#input\_db\_endpoint\_ssm\_name) | SSM parameter name for the database endpoint | `string` | `null` | no |
| <a name="input_db_host_ssm_name"></a> [db\_host\_ssm\_name](#input\_db\_host\_ssm\_name) | SSM parameter name for the database host | `string` | `null` | no |
| <a name="input_db_identifier"></a> [db\_identifier](#input\_db\_identifier) | Unique identifier for the database instance (e.g., main, secondary) | `string` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of the database to create | `string` | `"main"` | no |
| <a name="input_db_name_ssm_name"></a> [db\_name\_ssm\_name](#input\_db\_name\_ssm\_name) | SSM parameter name for the database name | `string` | `null` | no |
| <a name="input_db_password_ssm_name"></a> [db\_password\_ssm\_name](#input\_db\_password\_ssm\_name) | SSM parameter name for the database password | `string` | `null` | no |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | Port for the database engine (e.g., 5432 for postgres, 3306 for mysql) | `number` | n/a | yes |
| <a name="input_db_port_ssm_name"></a> [db\_port\_ssm\_name](#input\_db\_port\_ssm\_name) | SSM parameter name for the database port | `string` | `null` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Username for the database | `string` | `"admin"` | no |
| <a name="input_db_username_ssm_name"></a> [db\_username\_ssm\_name](#input\_db\_username\_ssm\_name) | SSM parameter name for the database username | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether to enable deletion protection | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Database engine (e.g., postgres, mysql, mariadb) | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Database engine version (e.g., 17.2 for postgres, 8.0 for mysql) | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, pre, pro) | `string` | n/a | yes |
| <a name="input_extra_security_group_rules"></a> [extra\_security\_group\_rules](#input\_extra\_security\_group\_rules) | List of extra security group rules to add to the managed security group.<br/>Only used if the security group is created by the module (i.e. no `security_group_id` or `security_group_tag_name` is given).<br/>Each rule must include the same arguments used in `aws_security_group_rule`, except `security_group_id`. | <pre>list(object({<br/>    type             = string # "ingress" or "egress"<br/>    from_port        = number<br/>    to_port          = number<br/>    protocol         = string<br/>    cidr_blocks      = optional(list(string))<br/>    ipv6_cidr_blocks = optional(list(string))<br/>    prefix_list_ids  = optional(list(string))<br/>    description      = optional(string)<br/>    self             = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_family"></a> [family](#input\_family) | DB parameter group family (e.g., postgres17, mysql8.0) | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | RDS instance class | `string` | `"db.t3.micro"` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | The amount of provisioned IOPS. Required if storage\_type is io1 or gp3 | `number` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Preferred maintenance window | `string` | `"Mon:00:00-Mon:02:00"` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Whether to let RDS manage the master password with automatic Secrets Manager integration. If `true`, disables local creation of Secrets Manager or SSM password. | `bool` | n/a | yes |
| <a name="input_manage_master_user_password_rotation"></a> [manage\_master\_user\_password\_rotation](#input\_manage\_master\_user\_password\_rotation) | Whether to enable automatic password rotation for the master user secret (only applies if `manage_master_user_password = true`) | `bool` | `false` | no |
| <a name="input_master_user_password_rotate_immediately"></a> [master\_user\_password\_rotate\_immediately](#input\_master\_user\_password\_rotate\_immediately) | Whether to rotate the master user password immediately upon creation | `bool` | `false` | no |
| <a name="input_master_user_password_rotation_automatically_after_days"></a> [master\_user\_password\_rotation\_automatically\_after\_days](#input\_master\_user\_password\_rotation\_automatically\_after\_days) | Number of days after which the master password should be rotated automatically | `number` | `null` | no |
| <a name="input_master_user_password_rotation_duration"></a> [master\_user\_password\_rotation\_duration](#input\_master\_user\_password\_rotation\_duration) | Duration of the rotation event (e.g., 1h, PT5M, ...) | `string` | `null` | no |
| <a name="input_master_user_password_rotation_schedule_expression"></a> [master\_user\_password\_rotation\_schedule\_expression](#input\_master\_user\_password\_rotation\_schedule\_expression) | Schedule expression for password rotation (e.g., `rate(30 days)`) | `string` | `null` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Maximum allocated storage for autoscaling | `number` | `0` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Whether to deploy in Multi-AZ | `bool` | `false` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | List of DB parameters to apply (parameter group will be created automatically) | `list(any)` | `[]` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Whether to enable Performance Insights | `bool` | `true` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Retention period for Performance Insights (in days) | `number` | `7` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Whether the RDS instance should be publicly accessible | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy resources in | `string` | n/a | yes |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | ID of an existing security group. If set, the module will not create a new one. | `string` | `null` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name of the security group for the RDS instance | `string` | `null` | no |
| <a name="input_security_group_tag_name"></a> [security\_group\_tag\_name](#input\_security\_group\_tag\_name) | Tag name of the existing security group to look up (only used if security\_group\_id is not set). | `string` | `""` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Type of storage (e.g., standard, gp2, gp3, io1) | `string` | `null` | no |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | Name of the DB subnet group for the RDS instance | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the RDS subnet group. If not set, subnet\_tag\_name will be used. | `list(string)` | `null` | no |
| <a name="input_subnet_tag_key"></a> [subnet\_tag\_key](#input\_subnet\_tag\_key) | Tag key used to search the subnets when subnet\_ids is not provided | `string` | `"type"` | no |
| <a name="input_subnet_tag_name"></a> [subnet\_tag\_name](#input\_subnet\_tag\_name) | Tag name of the subnets to look up | `string` | `""` | no |
| <a name="input_use_secrets_manager"></a> [use\_secrets\_manager](#input\_use\_secrets\_manager) | If true, store RDS credentials in AWS Secrets Manager instead of SSM Parameter Store | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the RDS instance will be deployed. If not set, vpc\_tag\_name will be used to look up the VPC. | `string` | `null` | no |
| <a name="input_vpc_tag_key"></a> [vpc\_tag\_key](#input\_vpc\_tag\_key) | Tag key used to search the VPC when vpc\_id is not provided | `string` | `"Name"` | no |
| <a name="input_vpc_tag_name"></a> [vpc\_tag\_name](#input\_vpc\_tag\_name) | Tag name of the VPC to look up | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_endpoint_ssm_name"></a> [db\_endpoint\_ssm\_name](#output\_db\_endpoint\_ssm\_name) | The name of the SSM parameter storing the database endpoint |
| <a name="output_db_host_ssm_name"></a> [db\_host\_ssm\_name](#output\_db\_host\_ssm\_name) | The name of the SSM parameter storing the database host |
| <a name="output_db_instance_address"></a> [db\_instance\_address](#output\_db\_instance\_address) | The address of the RDS instance |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | The endpoint of the RDS instance |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | The port of the RDS instance |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | The name of the database |
| <a name="output_db_name_ssm_name"></a> [db\_name\_ssm\_name](#output\_db\_name\_ssm\_name) | The name of the SSM parameter storing the database name |
| <a name="output_db_password_ssm_name"></a> [db\_password\_ssm\_name](#output\_db\_password\_ssm\_name) | The name of the SSM parameter storing the database password |
| <a name="output_db_port_ssm_name"></a> [db\_port\_ssm\_name](#output\_db\_port\_ssm\_name) | The name of the SSM parameter storing the database port |
| <a name="output_db_username"></a> [db\_username](#output\_db\_username) | The username for the database |
| <a name="output_db_username_ssm_name"></a> [db\_username\_ssm\_name](#output\_db\_username\_ssm\_name) | The name of the SSM parameter storing the database username |
| <a name="output_master_user_secret_arn"></a> [master\_user\_secret\_arn](#output\_master\_user\_secret\_arn) | RDS-managed secret ARN (if applicable) |
| <a name="output_secrets_manager_arn"></a> [secrets\_manager\_arn](#output\_secrets\_manager\_arn) | ARN of the RDS secrets stored in Secrets Manager (null if not used) |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group for the RDS instance |
| <a name="output_subnet_group_name"></a> [subnet\_group\_name](#output\_subnet\_group\_name) | The name of the DB subnet group for the RDS instance |

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
<!-- END_TF_DOCS -->