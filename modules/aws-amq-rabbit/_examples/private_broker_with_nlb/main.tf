module "amq_rabbit" {
  source = "../../"
  access_mode = "private_with_nlb"
  project_name = "myproject"
  environment  = "dev"
  mq_username = "admin"
  mq_password = "SuperSecretPassword123!"
  vpc_name = "my-vpc-name"
  broker_subnet_filter_tags = {
    Tier = "private"
    Type = "database"
  }
  lb_certificate_arn = "arn:aws:acm:region:account:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  allowed_ingress_cidrs = ["10.0.0.0/8", "192.168.0.0/16"]
  tags = {
    Owner      = "DevOps"
    CostCenter = "IT"
  }
}
