# API Key
api_key = "my-api-key"

# Instance
instance_name       = "my-cloudamqp-instance"
instance_plan       = "lemming"
instance_region     = "azure-arm::westeurope"
instance_nodes      = 3
instance_rqm_version = "3.11.0"
instance_tags       = ["production", "backend"]

# VPC
enable_vpc   = true
vpc_name     = "my-cloudamqp-vpc"
vpc_region   = "azure-arm::westeurope"
vpc_subnet   = ["10.0.0.0/24", "10.0.1.0/24"]
vpc_tags     = ["environment:production", "service:messaging"]
vpc_connect_approved_subscriptions = [
  "sub1-azure-region-east",
  "sub2-azure-region-west",
  "sub3-azure-region-south"
]

# Firewall
enable_firewall = true
firewall_rules = {
  "allow_ssh" = {
    description = "Allow SSH access"
    ip          = "0.0.0.0/0"
    ports       = ["22"]
    services    = []
  }
  "allow_rabbitmq" = {
    description = "Allow RabbitMQ traffic"
    ip          = "192.168.1.0/24"
    ports       = ["5672", "15672"]
    services    = []
  }
}

# Notifications
notifications = {
  "email_alert" = {
    type  = "email"
    value = "alerts@example.com"
    name  = "Email Alert"
  }
  "sms_alert" = {
    type  = "sms"
    value = "+1234567890"
    name  = "SMS Alert"
  }
}

# Alarms
alarms = {
  "high_cpu" = {
    type               = "cpu"
    enabled            = true
    reminder_interval  = 5
    value_threshold    = 80
    time_threshold     = 60
    recipients         = ["admin@example.com"]
  }
  "low_memory" = {
    type               = "memory"
    enabled            = true
    reminder_interval  = 10
    value_threshold    = 20
    time_threshold     = 60
    recipients         = ["admin@example.com"]
  }
}

# Metrics integration
enable_metrics = true
metrics_name   = "my-metrics"
metrics_api_key = "metrics-api-key"
metrics_region  = "us-west"
metrics_tags    = ["monitoring", "metrics"]

# Logs integration
enable_logs   = true
logs_name     = "my-logs"
logs_api_key  = "logs-api-key"
logs_region   = ["us-west-1", "us-east-1"]
logs_tags     = ["logging", "debug"]
