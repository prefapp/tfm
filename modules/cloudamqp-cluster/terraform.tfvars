# API Key
api_key = "xxxxxxx-xxxx-xxx-xxxxxxx" #Your api-key

# Instance
instance_name       = "my-cloudamqp-instance"
instance_plan       = "your-plan"
instance_region     = "azure-arm::westeurope"
instance_nodes      = 3
instance_rqm_version = "4.0.4"
instance_tags       = ["production", "backend"]


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

# Alarms
alarms = {
  "high_cpu" = {
    type               = "cpu"
    enabled            = true
    reminder_interval  = 30
    value_threshold    = 100
    time_threshold     = 60
    recipient_key = "admin_alert"
  }
  "low_memory" = {
    type               = "memory"
    enabled            = true
    reminder_interval  = 30
    value_threshold    = 10
    time_threshold     = 60
    recipient_key       = "admin2_alert"
  }
}

#Recipients
recipients = {
  "admin_alert" = {
    name = "admin alert 1"
    value = "admin1@example.com"
    type = "email"
  }
  "admin2_alert" = {
    name = "admin alert 2"
    value = "admin2@example.com"
    type = "email"
  }
}


# Metrics integration
enable_metrics = true
metrics_name   = "cloudwatch"
metrics_api_key = "metrics-api-key"
metrics_region  = "us-west-1"
metrics_tags    = {
  environment = "production"
  role = "monitoring"
}

# Logs integration
enable_logs   = true
logs_name     = "azure_monitor"
logs_api_key  = "logs-api-key"
logs_region   = ["us-west-1", "us-east-1"]
logs_tags     = ["logging", "debug"]
tenant_id        = "xxxxxxx-xxxx-xxxxx-xxxxxxxx"
application_id   = "xxxxxxx-xxxx-xxxxx-xxxxxxxx"
application_secret = "your-application-secret"
dce_uri          = "https://example.com/dce"
table            = "example_table_CL"
dcr_id           = "dcr-abc123xyz"
