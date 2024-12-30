## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_cloudamqp"></a> [cloudamqp](#requirement\_cloudamqp) | >= 1.32.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudamqp"></a> [cloudamqp](#provider\_cloudamqp) | >= 1.32.2 |

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

## Validations

- **Metrics Integrations:** The `metrics_integrations` map includes validation to ensure all required fields (e.g., `name`, `api_key`, `region`) are correctly configured. Invalid or missing data will result in a validation error during plan or apply stages.
- **Logs Integrations:** The `logs_integrations` map also enforces validation of variables, such as `name`, `api_key`, `region`, and Azure-specific fields (`tenant_id`, `application_id`, etc.), to guarantee proper integration with external log systems.

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
api_key = "your-api-key"

# Instance
cloudamqp_instance = {
  name        = "my-cloudamqp-instance"
  plan        = "your-plan"
  region      = "azure-arm::westeurope"
  tags        = ["production", "backend"]
  nodes       = 1
  rmq_version = "4.0.4"
}

# Firewall
enable_firewall = true
firewall_rules = {
  "allow_rabbitmq" = {
    description = "Allow RabbitMQ traffic"
    ip          = "192.168.1.0/24"
    ports       = ["15672"]
    services    = ["AMQP"]
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
    recipient_key     = "admin2_alert"
  }
}

#Recipients
recipients = {
  "admin_alert" = {
    name  = "admin alert 1"
    value = "admin1@example.com"
    type  = "email"
  }
  "admin2_alert" = {
    name  = "admin alert 2"
    value = "admin2@example.com"
    type  = "email"
  }
}


# Metrics integration
metrics_integrations = {
  cloudwatch = {
    name    = "cloudwatch"
    api_key = "metrics-api-key-cloudwatch"
    region  = "eu-west-1"
    tags = {
      environment = "production"
      role        = "monitoring"
    }
    access_key_id     = "AKIAIOSFODNN7EXAMPLE"
    secret_access_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    iam_role          = "arn:aws:iam::123456789012:role/example-role"
    iam_external_id   = "external-id-placeholder-123"
  }

  datadog = {
    name    = "datadog"
    api_key = "ddapikey1234567890abcdef1234567890"
    region  = "eu1"
    tags = {
      enviroment = "production" }
  }

  datadog_v2 = {
    name    = "datadog_v2"
    api_key = "ddapikey1234567890abcdef1234567890"
    region  = "eu1"
    tags = {
      enviroment = "staging" }
  }

  newrelic_v2 = {
    name    = "newrelic_v2"
    api_key = "NRAK-1234567890abcdef1234567890abcdef"
    region  = "us1"
    tags = {
      enviroment = "dev"
    license_key = "valid_license_key" }
  }

}


# Logs integration
logs_integrations = {
  azure_monitor_logs = {
    name    = "azure_monitor"
    api_key = "logs-api-key-azure"
    region  = ["us1", "eu"]
    tags = {
      environment = "production"
      role        = "logging"
    }
    tenant_id          = "11111111-1111-1111-1111-111111111111"
    application_id     = "abcdef12-3456-7890-abcd-ef1234567890"
    application_secret = "secret-azure"
    dce_uri            = "https://valid.endpoint.com"
    table              = "logs_CL"
    dcr_id             = "dcr-123abc"
  }
  datadog_logs = {
    name    = "datadog"
    api_key = "ddapikey1234567890abcdef1234567890"
    region  = ["us1"]
    tags = {
      environment = "production"
      role        = "monitoring"
    }
    tenant_id          = "datadog-tenant-id"
    application_id     = "datadog-app-id"
    application_secret = "secret-datadog"
    dce_uri            = "https://api.datadoghq.com"
    table              = "datadog_logs"
    dcr_id             = "dcr-123abc"
  }

  cloudwatch_logs = {
    name    = "cloudwatchlog"
    api_key = "logs-api-key-cloudwatch"
    region  = ["eu-west-1"]
    tags = {
      environment = "test"
      role        = "cloud-monitoring"
    }
    tenant_id          = "cloudwatch-tenant-id"
    application_id     = "cloudwatch-app-id"
    application_secret = "secret-cloudwatch"
    dce_uri            = "https://logs.us-west-2.amazonaws.com"
    table              = "cloudwatch_log_table"
    dcr_id             = "dcr-789ghi"
    access_key_id      = "AKIAIOSFODNN7EXAMPLE"
    secret_access_key  = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    iam_role           = "arn:aws:iam::123456789012:role/example-role"
    iam_external_id    = "external-id-placeholder-123"
  }

  stackdriver_logs = {
    name    = "stackdriver"
    api_key = "logs-api-key-stackdriver"
    region  = ["eu", "eu1"]
    tags = {
      environment = "development"
      role        = "logging"
    }
    project_id   = "your-gcp-project-id"
    private_key  = "your-private-key-content"
    client_email = "example@exaple.es"
  }
}



```
