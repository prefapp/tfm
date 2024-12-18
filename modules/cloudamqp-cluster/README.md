## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_cloudamqp"></a> [cloudamqp](#requirement\_cloudamqp) | >= 1.32.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudamqp"></a> [cloudamqp](#provider\_cloudamqp) | >= 1.32.1 |

## Resources

| Name | Type |
|------|------|
| [cloudamqp_instance.instance](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/resources/instance) | resource |
| [cloudamqp_alarm.this](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/resources/alarm) | resource |
| [cloudamqp_notification.recipient](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/resources/notification) | resource |
| [cloudamqp_integration_log.logs](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/resources/integration_log) | resource |
| [cloudamqp_integration_metric.this](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/resources/integration_metric) | resource |
| [cloudamqp_security_firewall.this](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/resources/security_firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | API key for CloudAMQP | `string` | n/a | yes |
| <a name="input_instance_plan"></a> [instance\_plan](#input_instance_plan) | Plan for the CloudAMQP instance ([List of plans](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/guides/info_plan)) | `string` | n/a | yes |
| <a name="input_instance_region"></a> [instance\_region](#input_instance_region) | Region for the CloudAMQP instance | `string` | n/a | yes |
| <a name="input_instance_nodes"></a> [instance\_nodes](#input_instance_nodes) | Number of nodes for the CloudAMQP instance | `number` | n/a | yes |
| <a name="input_instance_rmq_version"></a> [instance\_rmq\_version](#input_instance_rmq_version) | RabbitMQ version for the CloudAMQP instance | `string` | n/a | yes |
| <a name="input_instance_tags"></a> [instance\_tags](#input_instance_tags) | Tags for the CloudAMQP instance | `list(string)` | `[]` | no |

| <a name="input_enable_firewall"></a> [enable\_firewall](#input\_enable\_firewall) | Enable firewall configuration | `bool` | `false` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Firewall rules for the instance | `map(object({ description = string, ip = string, ports = list(string), services = list(string) }))` | `{}` | no |
| <a name="input_recipients"></a> [recipients](#input\_recipients) | Map of notification recipients | `map(object({ value = string, name = string, type = string }))` | `{}` | no |
| <a name="input_alarms"></a> [alarms](#input\_alarms) | Map of alarms for monitoring | `map(object({ type = string, enabled = bool, reminder_interval = number, value_threshold = number, time_threshold = number, recipient_key = string }))` | `{}` | no |
| <a name="input_metrics_integrations"></a> [metrics\_integrations](#input\_metrics\_integrations) | Map of metrics integrations | `map(object({ name = string, api_key = string, region = string, tags = map(string) }))` | `{}` | no |
| <a name="input_logs_integrations"></a> [logs\_integrations](#input\_logs\_integrations) | Map of logs integrations | `map(object({ name = string, api_key = string, region = list(string), tags = map(string), tenant_id = string, application_id = string, application_secret = string, dce_uri = string, table = string, dcr_id = string }))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | ID of the CloudAMQP instance |
| <a name="output_cloudamqp_instance_rqm_version"></a> [cloudamqp\_instance\_rqm\_version](#output\_cloudamqp\_instance\_rqm\_version) | RabbitMQ version of the CloudAMQP instance |
| <a name="output_instance_host"></a> [instance\_host](#output\_instance\_host) | Host of the CloudAMQP instance |
| <a name="output_instance_vhost"></a> [instance\_vhost](#output\_instance\_vhost) | Virtual host of the CloudAMQP instance |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID of the CloudAMQP instance |
| <a name="output_instance_url"></a> [instance\_url](#output\_instance\_url) | URL of the CloudAMQP instance (**Sensitive**) |
| <a name="output_instance_api_key"></a> [instance\_api\_key](#output\_instance\_api\_key) | API Key for accessing the CloudAMQP instance (**Sensitive**) |
| <a name="output_instance_host_internal"></a> [instance\_host\_internal](#output\_instance\_host\_internal) | Internal host of the CloudAMQP instance (**Sensitive**) |
| <a name="output_instance_vhost_dedicated"></a> [instance\_vhost\_dedicated](#output\_instance\_vhost\_dedicated) | Dedicated virtual host of the CloudAMQP instance |
| <a name="output_instance_dedicated"></a> [instance\_dedicated](#output\_instance\_dedicated) | Whether the instance is dedicated or shared |
| <a name="output_instance_backend"></a> [instance\_backend](#output\_instance\_backend) | Backend type of the CloudAMQP instance |


## Example

```yaml
# API Key
api_key = "Your-cloudamqp-api-key"

# Instance
instance_name        = "my-cloudamqp-instance"
instance_plan        = "your-plan"
instance_region      = "azure-arm::westeurope"
instance_nodes       = 3
instance_rqm_version = "4.0.4"
instance_tags        = ["production", "backend"]


# Firewall
enable_firewall = true
firewall_rules = {
  "allow_rabbitmq" = {
    description = "Allow RabbitMQ traffic"
    ip          = "exampled-ip"
    ports       = ["5672", "15672"]
    services    = []
  }
}

# Alarms
alarms = {
  "high_cpu" = {
    type              = "cpu"
    enabled           = true
    reminder_interval = 30
    value_threshold   = 100
    time_threshold    = 60
    recipient_key     = "admin_alert"
  }
  "low_memory" = {
    type              = "memory"
    enabled           = true
    reminder_interval = 30
    value_threshold   = 10
    time_threshold    = 60
    recipient_key     = "admin_alert"
  }
}

#Recipients
recipients = {
  "admin_alert" = {
    name  = "admin alert"
    value = "admin@example.com"
    type  = "email"
}


# Metrics integration
metrics_integrations = {
  cloudwatch = {
    name    = "cloudwatch"
    api_key = "metrics-api-key-cloudwatch"
    region  = "us-west-1"
    tags = {
      environment = "production"
      role        = "monitoring"
    }
} }


# Logs integration
logs_integrations = {
  azure_monitor = {
    name    = "azure_monitor"
    api_key = "logs-api-key-azure"
    region  = ["us-west-1", "us-east-1"]
    tags = {
      environment = "production"
      role        = "logging"
    }
    tenant_id          = "your-tenant-id"
    application_id     = "your-application-id"
    application_secret = "your-aplication-secret"
    dce_uri            = "https://valid.endpoint.com"
    table              = "logs_CL"
    dcr_id             = "valid-dcr_id"
  }
}

```
