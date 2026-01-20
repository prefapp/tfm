module "amq_rabbit" {
  source = "../../"
  access_mode = "private_with_nlb"
  project_name = "myproject"
  environment  = "dev"
  mq_username = "admin"
  vpc_name = "my-vpc-name"
  broker_subnet_filter_tags = {
    Tier = "private"
    Type = "database"
  }
  lb_certificate_arn = "arn:aws:acm:region:account:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  allowed_ingress_cidrs = ["10.0.0.0/8", "192.168.0.0/16"]
  nlb_listener_ips = [
    {
      ips = ["10.0.1.10", "10.0.2.10"]
      target_port = 5671 # AMQPS
    },
    # You can use either the port number or the name for Management UI. Both resolve to the same host/IP.
    {
      ips = ["10.0.1.10", "10.0.2.10"]
      target_port = 443 # Management UI (RabbitMQ)
    },
    {
      ips = ["10.0.1.10", "10.0.2.10"]
      target_port = "Management UI" # also valid, resolves to port 443
    }
  ]
  tags = {
    Owner      = "DevOps"
    CostCenter = "IT"
  }
}
