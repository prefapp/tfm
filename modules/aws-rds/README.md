# RDS Database Module

This Terraform module deploys an AWS RDS instance for various database engines (PostgreSQL, MySQL, MariaDB, etc.), along with associated resources like security groups, subnet groups, and SSM parameters for storing credentials and connection details.

- `region`: AWS region to deploy resources in.
- `environment`: Environment name (e.g., dev, pre, pro).
- `db_identifier`: Unique identifier for the database instance.

### Networking
- `vpc_id`: ID of the VPC where the RDS instance will be deployed (optional if `vpc_tag_name` is used).
- `vpc_tag_name`: Tag name of the VPC to look up (used if `vpc_id` is not provided).
- `subnet_ids`: List of subnet IDs to use (optional if `subnet_tag_name` is used).
- `subnet_tag_name`: Tag name of the subnets to look up.

### Database
- `engine`: Database engine (e.g., postgres, mysql, mariadb).
- `db_port`: Port for the database engine (e.g., 5432 for postgres, 3306 for mysql).
- `db_name`: Name of the database to create (default: "main").
- `db_username`: Username for the database (default: "admin").
- `engine_version`: Database engine version (e.g., 17.2 for postgres, 8.0 for mysql).
- `family`: DB parameter group family (e.g., postgres17, mysql8.0).
- `manage_master_user_password`: Whether to manage the master user password.
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

### SSM Parameter Store
- `db_name_ssm_name`: SSM parameter name for the database name (default: `<engine>/<environment>/<db_identifier>/name`).
- `db_username_ssm_name`: SSM parameter name for the database username (default: `<engine>/<environment>/<db_identifier>/username`).
- `db_password_ssm_name`: SSM parameter name for the database password (default: `<engine>/<environment>/<db_identifier>/password`).
- `db_endpoint_ssm_name`: SSM parameter name for the database endpoint (default: `<engine>/<environment>/<db_identifier>/endpoint`).
- `db_host_ssm_name`: SSM parameter name for the database host (default: `<engine>/<environment>/<db_identifier>/host`).
- `db_port_ssm_name`: SSM parameter name for the database port (default: `<engine>/<environment>/<db_identifier>/port`).

### Security Groups
- `security_group_name`: Name of the security group for the RDS instance (default: `<engine>-<environment>-<db_identifier>-security-group`).
- `security_group_id`: ID of an existing security group to attach to the instance (optional).
- `security_group_tag_name`: Tag name to look up an existing security group (optional, used if `security_group_id` is not provided).
- `extra_security_group_rules`: List of additional security group rules (only applied if the module creates the security group).
- `subnet_group_name`: The name of the DB subnet group for the RDS instance.

## Usage
### PostgreSQL Example with Custom SSM, Security Group, and Subnet Group Names
```hcl
module "rds_postgres_dev" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-rds"

  region                                = "eu-west-1"
  environment                           = "dev"
  db_identifier                         = "main"
  vpc_tag_name                          = "k8s-org-vpc"
  subnet_tag_name                       = "private"
  engine                                = "postgres"
  db_port                               = 5432
  db_name                               = "main"
  db_username                           = "postgres"
  db_name_ssm_name                      = "postgres/dev/main/name"
  db_username_ssm_name                  = "postgres/dev/main/username"
  db_password_ssm_name                  = "postgres/dev/main/password"
  db_endpoint_ssm_name                  = "postgres/dev/main/endpoint"
  db_host_ssm_name                      = "postgres/dev/main/host"
  db_port_ssm_name                      = "postgres/dev/main/port"
  security_group_name                   = "postgres-dev-main-security-group"
  subnet_group_name                     = "postgres-dev-main-subnet-group"
  engine_version                        = "17.2"
  family                                = "postgres17"
  instance_class                        = "db.t3.micro"
  allocated_storage                     = 50
  deletion_protection                   = true
  max_allocated_storage                 = 100
  multi_az                              = false
  backup_retention_period               = 3
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  publicly_accessible                   = false
  manage_master_user_password           = false
  maintenance_window                    = "Tue:00:00-Tue:02:00"
  backup_window                         = "03:00-06:00"
  parameters                            = [
                                          {
                                            name    = "log_statement"
                                            value   = "ddl"
                                          },
                                          {
                                            name    = "log_min_duration_statement"
                                            value   = "500"
                                          },
                                          {
                                            name    = "max_connections"
                                            value   = "150"
                                          }
                                        ]
  extra_security_group_rules            = [
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
