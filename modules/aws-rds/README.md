# RDS Database Module

This Terraform module deploys an AWS RDS instance for various database engines (PostgreSQL, MySQL, MariaDB, etc.), along with associated resources like security groups, subnet groups, and optionally stores credentials and connection details in either SSM Parameter Store or AWS Secrets Manager.

## Features
- Automatic provisioning of RDS resources
- Support for PostgreSQL, MySQL, MariaDB, and more
- Configurable SSM Parameter Store integration
- Optional support for AWS Secrets Manager to store DB credentials
- Optional support for native RDS-managed Secrets Manager integration with automatic password rotation
- Custom security group and subnet group support
- Additional security group rule injection
- Backup and performance settings

## Inputs

### General
- `region`: AWS region to deploy resources in.
- `environment`: Environment name (dev, pre, pro, etc.).
- `db_identifier`: Unique identifier for the database instance.

### Networking
- `vpc_id`: ID of the VPC where the RDS instance will be deployed (optional if `vpc_tag_name` is used).
- `vpc_tag_name`: Tag name of the VPC to look up (used if `vpc_id` is not provided).
- `subnet_ids`: List of subnet IDs to use (optional if `subnet_tag_name` is used).
- `subnet_tag_name`: Tag name of the subnets to look up.

### Database
- `engine`: Database engine (postgres, mysql, mariadb, etc.).
- `db_port`: Port for the database engine (e.g., 5432 for postgres, 3306 for mysql).
- `db_name`: Name of the database to create (default: "main").
- `db_username`: Username for the database (default: "admin").
- `engine_version`: Database engine version (17.2 for postgres, 8.0 for mysql, etc.).
- `family`: DB parameter group family (postgres17, mysql8.0, etc.).
- `instance_class`: RDS instance class (default: "db.t3.micro").
- `allocated_storage`: Allocated storage in GB (default: 50).
- `max_allocated_storage`: Maximum allocated storage for autoscaling (default: 0).
- `deletion_protection`: Whether to enable deletion protection (default: false).
- `multi_az`: Whether to deploy in Multi-AZ (default: false).
- `backup_retention_period`: Number of days to retain backups (default: 3).
- `performance_insights_enabled`: Whether to enable Performance Insights (default: true).
- `performance_insights_retention_period`: Retention period for Performance Insights in days (default: 7).
- `publicly_accessible`: Whether the RDS instance should be publicly accessible (default: false).
- `maintenance_window`: Preferred maintenance window (default: "Mon:00:00-Mon:02:00").
- `backup_window`: Preferred backup window (default: `null`).
- `storage_type`: Type of storage (`standard`, `gp2`, `gp3`, `io1`) (default: `null`).
- `iops`: Provisioned IOPS if using `io1` or `gp3` (default: `null`).
- `parameters`: List of DB parameters to set in the parameter group (default: `[]`).
- `apply_immediately`: Whether to apply changes immediately (default: `false`).
- `allow_major_version_upgrade`: Whether to allow major engine version upgrades (default: `false`).

### Master User Password Management
- `manage_master_user_password`: Whether to let RDS manage the master password with automatic Secrets Manager integration. If `true`, disables local creation of Secrets Manager or SSM password.
- `manage_master_user_password_rotation`: Whether to enable automatic password rotation for the master user secret (only applies if `manage_master_user_password = true`) (default: false).
- `master_user_password_rotate_immediately`: Whether to rotate the master password immediately upon creation (default: `false`).
- `master_user_password_rotation_automatically_after_days`: Number of days after which to automatically rotate the password (default: `null`).
- `master_user_password_rotation_duration`: Duration of the rotation process (e.g., `1h`) (default: `null`).
- `master_user_password_rotation_schedule_expression`: Schedule expression for password rotation (e.g., `rate(30 days)`) (default: `null`).

### SSM Parameter Store
(Only used if `use_secrets_manager = false` and `manage_master_user_password = false`)
- `use_secrets_manager`: If true, stores and reads credentials from AWS Secrets Manager instead of SSM (default: false).
- `db_name_ssm_name`: SSM parameter name for the database name (default: `<engine>/<environment>/<db_identifier>/name`).
- `db_username_ssm_name`: SSM parameter name for the database username (default: `<engine>/<environment>/<db_identifier>/username`).
- `db_password_ssm_name`: SSM parameter name for the database password (default: `<engine>/<environment>/<db_identifier>/password`).
- `db_endpoint_ssm_name`: SSM parameter name for the database endpoint (default: `<engine>/<environment>/<db_identifier>/endpoint`).
- `db_host_ssm_name`: SSM parameter name for the database host (default: `<engine>/<environment>/<db_identifier>/host`).
- `db_port_ssm_name`: SSM parameter name for the database port (default: `<engine>/<environment>/<db_identifier>/port`).

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

### Security Groups
- `security_group_name`: Name of the security group for the RDS instance (default: `<engine>-<environment>-<db_identifier>-security-group`).
- `security_group_id`: ID of an existing security group to attach to the instance (optional).
- `security_group_tag_name`: Tag name to look up an existing security group (optional, used if `security_group_id` is not provided).
- `extra_security_group_rules`: List of additional security group rules (only applied if the module creates the security group).
- `subnet_group_name`: The name of the DB subnet group for the RDS instance.

### Outputs
- `db_instance_endpoint`: The full RDS endpoint
- `db_instance_address`: The hostname of the RDS instance
- `db_instance_port`: Port of the instance
- `db_name`: Name of the DB
- `db_username`: DB username
- `db_password_ssm_name`: SSM name of the password (only if not using Secrets Manager or RDS-managed password)
- `db_name_ssm_name`: SSM name of the DB name (only if not using Secrets Manager or RDS-managed password)
- `db_username_ssm_name`: SSM name of the username (only if not using Secrets Manager or RDS-managed password)
- `db_endpoint_ssm_name`: SSM name of the full endpoint (only if not using Secrets Manager or RDS-managed password)
- `db_host_ssm_name`: SSM name of the hostname (only if not using Secrets Manager or RDS-managed password)
- `db_port_ssm_name`: SSM name of the port (only if not using Secrets Manager or RDS-managed password)
- `security_group_id`: Security group ID used
- `subnet_group_name`: Name of the DB subnet group
- `secrets_manager_arn`: ARN of the Secrets Manager secret (only if `use_secrets_manager = true` and `manage_master_user_password = false`)
- `master_user_secret_arn`: ARN of the RDS-managed Secrets Manager secret (only if `manage_master_user_password = true`)

## Usage
### Example 1: PostgreSQL using SSM Parameter Store (default)
```hcl
module "rds_postgres_ssm" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-rds"

  region                  = "eu-west-1"
  environment             = "dev"
  db_identifier           = "main"
  vpc_tag_name            = "k8s-org-vpc"
  subnet_tag_name         = "private"

  engine                  = "postgres"
  engine_version          = "17.2"
  family                  = "postgres17"
  db_port                 = 5432
  db_name                 = "main"
  db_username             = "postgres"

  manage_master_user_password = false
  use_secrets_manager         = false

  db_name_ssm_name      = "postgres/dev/main/name"
  db_username_ssm_name  = "postgres/dev/main/username"
  db_password_ssm_name  = "postgres/dev/main/password"
  db_endpoint_ssm_name  = "postgres/dev/main/endpoint"
  db_host_ssm_name      = "postgres/dev/main/host"
  db_port_ssm_name      = "postgres/dev/main/port"

  security_group_name   = "postgres-dev-main-security-group"
  subnet_group_name     = "postgres-dev-main-subnet-group"

  instance_class        = "db.t3.micro"
  allocated_storage     = 50
  max_allocated_storage = 100
  multi_az              = false
  deletion_protection   = true

  backup_retention_period               = 3
  backup_window                         = "03:00-06:00"
  maintenance_window                    = "Tue:00:00-Tue:02:00"
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  publicly_accessible                   = false

  parameters = [
    {
      name  = "log_statement"
      value = "ddl"
    },
    {
      name  = "log_min_duration_statement"
      value = "500"
    },
    {
      name  = "max_connections"
      value = "150"
    }
  ]

  extra_security_group_rules = [
    {
      type        = "ingress"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Allow access from app"
    }
  ]
}
```
### Example 2: MySQL using Secrets Manager
```hcl
module "rds_mysql_secrets" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-rds"

  region                  = "eu-west-1"
  environment             = "pro"
  db_identifier           = "myapp"
  vpc_tag_name            = "main-vpc"
  subnet_tag_name         = "rds"

  engine                  = "mysql"
  engine_version          = "8.0"
  family                  = "mysql8.0"
  db_port                 = 3306
  db_name                 = "production"
  db_username             = "admin"

  manage_master_user_password = false
  use_secrets_manager         = true

  security_group_name   = "mysql-pro-myapp-sg"
  subnet_group_name     = "mysql-pro-myapp-subnet"

  instance_class        = "db.t3.medium"
  allocated_storage     = 100
  max_allocated_storage = 200
  multi_az              = true
  deletion_protection   = true

  backup_retention_period               = 7
  backup_window                         = "04:00-06:00"
  maintenance_window                    = "Sun:03:00-Sun:04:00"
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  publicly_accessible                   = false

  extra_security_group_rules = [
    {
      type        = "ingress"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["192.168.0.0/16"]
      description = "Allow MySQL traffic from internal network"
    }
  ]
}
```
### Example 3: PostgreSQL with RDS-managed Secret and Automatic Rotation
```hcl
module "rds_postgres_managed_secret" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-rds"

  region                  = "eu-west-1"
  environment             = "pre"
  db_identifier           = "rotated"
  vpc_tag_name            = "core-vpc"
  subnet_tag_name         = "private"

  engine                  = "postgres"
  engine_version          = "17.2"
  family                  = "postgres17"
  db_port                 = 5432
  db_name                 = "rotatedb"
  db_username             = "postgres"

  manage_master_user_password                     = true
  manage_master_user_password_rotation            = true
  master_user_password_rotate_immediately         = true
  master_user_password_rotation_automatically_after_days = 30
  master_user_password_rotation_duration          = "2h"
  master_user_password_rotation_schedule_expression = "rate(30 days)"

  instance_class        = "db.t3.small"
  allocated_storage     = 100
  max_allocated_storage = 200
  multi_az              = false
  deletion_protection   = true

  backup_retention_period               = 5
  maintenance_window                    = "Wed:01:00-Wed:02:00"
  backup_window                         = "01:00-03:00"
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  publicly_accessible                   = false

  subnet_group_name     = "postgres-pre-rotated-subnet"
  security_group_name   = "postgres-pre-rotated-sg"

  extra_security_group_rules = [
    {
      type        = "ingress"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["172.31.0.0/16"]
      description = "Allow traffic from internal apps"
    }
  ]
}

```
