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

  manage_master_user_password = true
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
