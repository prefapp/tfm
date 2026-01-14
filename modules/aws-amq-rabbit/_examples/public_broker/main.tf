module "amq_rabbit" {
  source                  = "../../"
  access_mode             = "public"
  project_name            = "myproject"
  environment             = "dev"
  mq_username             = "admin"
  vpc_id                  = "vpc-xxxxxxxx"
  broker_subnet_ids       = ["subnet-xxxxxxxx"]
  exposed_ports           = [5671]
  host_instance_type      = "mq.t3.micro"
  engine_version          = "3.13"
  deployment_mode         = "SINGLE_INSTANCE"
  enable_cloudwatch_logs  = true
  allowed_ingress_cidrs   = ["0.0.0.0/0"]
  tags = {
    Owner      = "DevOps"
    CostCenter = "IT"
  }
}
