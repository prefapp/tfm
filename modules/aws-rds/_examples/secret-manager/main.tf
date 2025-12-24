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
