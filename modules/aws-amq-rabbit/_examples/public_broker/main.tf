module "amq_rabbit" {
  source = "../../"
  access_mode = "public"
  project_name = "myproject"
  environment  = "dev"
  mq_username = "admin"
  mq_password = "SuperSecretPassword123!"
  vpc_id = "vpc-xxxxxxxx"
  broker_subnet_ids = ["subnet-xxxxxxxx"]
  lb_certificate_arn = "arn:aws:acm:region:account:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  allowed_ingress_cidrs = ["0.0.0.0/0"]
  tags = {
    Owner      = "DevOps"
    CostCenter = "IT"
  }
}
