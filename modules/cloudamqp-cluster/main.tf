# Configure the CloudAMQP Provider
provider "cloudamqp" {
  apikey          = "3569bf29-972d-4e5d-8caa-a075fe66781a"
}

# Create a new cloudamqp instance
resource "cloudamqp_instance" "instance" {
  name          = "terraform-cloudamqp-instance"
  plan          = "lemming"
  region        = "azure-arm::westeurope"
  tags          = [ "terraform" ]
}

terraform {
  required_providers {
    cloudamqp = {
      source = "cloudamqp/cloudamqp"
      version = "1.32.1"
    }
  }
}

# Separación de recursos por .tf
# Optional VPC
resource "cloudamqp_vpc" "vpc" {
  count = var.enable_vpc ? 1 : 0
  name = var.vpc_name
  region = var.vpc_region
  subnet = var.vpc_subnet
  tags = var.vpc_tags
}

# Optional VPC connect
resource "cloudamqp_vpc_connect" "vpc_connect" {
  count = var.enable_vpc_connect ? 1 : 0
  instance_id = cloudamqp_instance.instance.id
  region = var.cloudamqp_instance_region
  approved_subscription = var.vpc_connect_approved_subscriptions
  depends_on = [cloudamqp_vpc.vpc]
}


# Firewall rules
resource "cloudamqp_security_firewall" "firewall" {
  count = var.enable_firewall ? 1 : 0
  instance_id = cloudamqp_instance.instance.id

  dynamic "rules" {
    for_each = var.firewall_rules
    content {
      description = rules.value["description"]
      ip = rules.value["ip"]
      ports = rules.value["ports"]
      services = rules.value["services"]
    }
  }
}

# Notifications (cambiar por for_each)
resource "cloudamqp_notification" "notifications" {
  count = leght(var.notifications)

  instance_id = cloudamqp_instance.instance.id
  type = var.notifications[count.index].type
  value = var.notifications[count.index].value
  name = var.notifications[count.index].name
}

# Alarms
resource "cloudamqp_alarms" "alarms" {
  count = leght(var.alarms)

  instance_id = cloudamqp_instance.instance.id
  type = var.alarms[count.index].type
  enabled = var.alarms[count.index].enabled
  reminder_interval = var.alarms[count.index].reminder_interval
  value_threshold = var.alarms[count.index].value_threshold
  time_threshold = var.alarms[count.index].time_threshold
  recipients = var.alarms[count.index].recipients
}

# Metrics integration
resource "cloudamqp_integration_metric" "metrics" {
  count = var.enable_metrics ? 1 : 0
  instance_id = cloudamqp_instance.instance.id
  name = var.metrics_name
  api_key = var.metrics_api_key
  region = var.metrics_region
  tags = var.metrics_tags
}

# Logs Integration (Añadir integración para API KEY de archivo externo (data sobre keyvault))
resource "cloudamqp_integration_log" "logs" {
  count = var.enable_logs ? 1 : 0
  instance_id = cloudamqp_instance.instance.id
  name = var.logs_name
  api_key = var.logs_api_key
  region = var.logs_region
  tags = var.logs_tags
}
