module "amq_rabbit" {
  source                  = "../../"
  access_mode             = "private"
  project_name            = "myproject"
  environment             = "dev"
  mq_username             = "admin"
  vpc_name                = "my-vpc-name"
  broker_subnet_filter_tags = {
    Tier = "private"
    Type = "database"
  }
  exposed_ports           = [5671]
  host_instance_type      = "mq.t3.micro"
  engine_version          = "3.13"
  deployment_mode         = "SINGLE_INSTANCE"
  enable_cloudwatch_logs  = true
  allowed_ingress_cidrs   = ["10.0.0.0/8", "192.168.0.0/16"]
  tags = {
    Owner      = "DevOps"
    CostCenter = "IT"
  }
}
