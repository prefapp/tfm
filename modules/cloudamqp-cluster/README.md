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
| [cloudamqp_instance.this](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/resources/instance) | resource |
| [cloudamqp_alarm.this](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/resources/alarm) | resource |
| [cloudamqp_notification.this](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/resources/notification) | resource |
| [cloudamqp_integration_log.this](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/resources/integration_log) | resource |
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
| <a name="input_no_default_alarms"></a> [no\_default\_alarms](#input\_no\_default\_alarms) | Disable the default alarms created for the CloudAMQP instance | `bool` | `false` | no |
| <a name="input_keep_associated_vpc"></a> [keep\_associated\_vpc](#input\_keep\_associated\_vpc) | Preserve the associated VPC when the CloudAMQP instance is deleted | `bool` | `false` | no |
| <a name="input_enable_firewall"></a> [enable\_firewall](#input\_enable\_firewall) | Enable firewall configuration | `bool` | `false` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Firewall rules for the instance | `map(object({ description = string, ip = string, ports = list(string), services = list(string) }))` | `{}` | no |
| <a name="input_recipients"></a> [recipients](#input\_recipients) | Map of notification recipients | `map(object({ value = string, name = string, type = string }))` | `{}` | no |
| <a name="input_alarms"></a> [alarms](#input\_alarms) | Map of alarms for monitoring | `map(object({ type = string, enabled = bool, reminder_interval = number, value_threshold = number, time_threshold = number, recipient_key = string }))` | `{}` | no |
| <a name="input_metrics_integrations"></a> [metrics\_integrations](#input\_metrics\_integrations) | Map of metrics integrations | `map(object({ name = string, api_key = string, region = string, tags = map(string) }))` | `{}` | no |
| <a name="input_logs_integrations"></a> [logs\_integrations](#input\_logs\_integrations) | Map of logs integrations | `map(object({ name = string, api_key = string, region = string, tags = map(string), tenant_id = string, application_id = string, application_secret = string, dce_uri = string, table = string, dcr_id = string }))` | `{}` | no |

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


## Example 1: tfvars

```yaml
#tfvars
terraform {
  required_providers {
    cloudamqp = {
      source  = "cloudamqp/cloudamqp"
      version = ">= 1.32.2"
    }
  }
  required_version = ">= 1.7.0"
}

provider "cloudamqp" {
  api_key = var.api_key
}
cloudamqp_instance = {

  api_key   = var.api_key
  plan      = "your-plan"
  region    = "your-region"
  nodes     = 1
  rmq_version = "4.0.4"
  tags      = ["production", "messaging"]
  }

  enable_firewall  = true
  firewall_rules = {
    rule1 = {
      description = "Allow access from office network"
      ip          = "203.0.113.0"
      ports       = ["5672", "15672"]
      services    = ["rabbitmq"]
    },
    rule2 = {
      description = "Allow monitoring tools"
      ip          = "198.51.100.0"
      ports       = ["443"]
      services    = ["monitoring"]
    }
  }

  recipients = {
    admin = {
      value = "admin@example.com"
      name  = "Admin"
      type  = "email"
    }
  }

  alarms = {
    high_memory_usage = {
      type             = "memory"
      enabled          = true
      reminder_interval = 30
      value_threshold   = 80
      time_threshold    = 5
      recipient_key     = "admin"
    }
  }

  metrics_integrations = {
    datadog = {
      name    = "datadog"
      api_key = "your-datadog-api-key"
      region  = "us-east-1"
      tags    = { environment = "production" }
    }
  }

  logs_integrations = {
    azure = {
      name              = "azure-log-analytics"
      api_key           = "your-azure-api-key"
      region            = "us-east-1"
      tags              = { environment = "production" }
      tenant_id         = "your-tenant-id"
      application_id    = "your-application-id"
      application_secret = "your-application-secret"
      dce_uri           = "https://example.com"
      table             = "logs"
      dcr_id            = "your-dcr-id"
    }
  }
}
```
## Example 2: yaml

```yaml
#Claim
kind: YourKind
lifecycle: production
name: name-of-your-instance
system: 'your-system'
version: '1.0'
providers:
  terraform:
    tfStateKey: xxxxxx-xxxx-xxxx-xxxxxx
    source: remote
    module: git::https://this.module.ref.com
    values:
      cloudamqp_instance:
        key: "${var.api_key}"
        plan: "your-plan"
        region: "your-region"
        nodes: 1
        rmq_version: "4.0.4"
        tags:
          - "production"
          - "messaging"

      enable_firewall: true
      firewall_rules:
        rule1:
          description: "Allow access from office network"
          ip: "203.0.113.0"
          ports:
            - "5672"
            - "15672"
          services:
            - "rabbitmq"
        rule2:
          description: "Allow monitoring tools"
          ip: "198.51.100.0"
          ports:
            - "443"
          services:
            - "monitoring"

      recipients:
        admin:
          value: "admin@example.com"
          name: "Admin"
          type: "email"

      alarms:
        high_memory_usage:
          type: "memory"
          enabled: true
          reminder_interval: 30
          value_threshold: 80
          time_threshold: 5
          recipient_key: "admin"

      metrics_integrations:
        datadog:
          name: "datadog"
          api_key: "your-datadog-api-key"
          region: "us-east-1"
          tags:
            environment: "production"

      logs_integrations:
        azure:
          name: "azure-log-analytics"
          api_key: "your-azure-api-key"
          region: "us-east-1"
          tags:
            environment: "production"
          tenant_id: "your-tenant-id"
          application_id: "your-application-id"
          application_secret: "your-application-secret"
          dce_uri: "https://example.com"
          table: "logs"
          dcr_id: "your-dcr-id"

    context:
      providers:
        - name: your-provider
      backend:
        name: azure-backend-terraform
```
