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
