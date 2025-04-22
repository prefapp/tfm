# Cloudamqp cluster module

This terraform module creates a Cloudamqp cluster (with your instance/s) and create a associated VPC. Which means that before creating a resource it must have a VPC.

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
| <a name="input_plan"></a> [plan](#input_plan) | Plan for the CloudAMQP instance ([List of plans](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/guides/info_plan)) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input_region) | Region for the CloudAMQP instance and associated VPC | `string` | n/a | yes |
| <a name="input_nodes"></a> [nodes](#input_nodes) | Number of nodes for the CloudAMQP instance | `number` | n/a | yes |
| <a name="input_rmq_version"></a> [rmq\_version](#input_rmq_version) | RabbitMQ version for the CloudAMQP instance | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input_tags) | Tags for the CloudAMQP instance | `list(string)` | `[]` | no |
| <a name="input_no_default_alarms"></a> [no\_default\_alarms](#input\_no\_default\_alarms) | Disable the default alarms created for the CloudAMQP instance | `bool` | `false` | no |
| <a name="vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC to associate with the CloudAMQP instance | `string` | n/a | yes |
| <a name="input_keep_associated_vpc"></a> [keep\_associated\_vpc](#input\_keep\_associated\_vpc) | Preserve the associated VPC when the CloudAMQP instance is deleted | `bool` | `false` | no |
| <a name="input_cloudamqp_vpc_connect.instance_id"></a> [cloudamqp\_vpc\_connect.instance\_id](#input\_cloudamqp\_vpc\_connect.instance\_id) | ID of the CloudAMQP instance to connect to the VPC | `number` | n/a | yes |
| <a name="input_cloudamqp_vpc_connect.approved_subscriptions"></a> [cloudamqp\_vpc\_connect.approved\_subscriptions](#input\_cloudamqp\_vpc\_connect.approved\_subscriptions) | List of approved subscriptions for the VPC connection | `list(string)` | `[]` | no |
| <a name="input_cloudamqp_vpc_connect.sleep"></a> [cloudamqp\_vpc\_connect.sleep](#input\_cloudamqp\_vpc\_connect.sleep) | Sleep time before checking the VPC connection status | `number` | `30` | no |
| <a name="input_cloudamqp_vpc_connect.timeout"></a> [cloudamqp\_vpc\_connect.timeout](#input\_cloudamqp\_vpc\_connect.timeout) | Timeout for the VPC connection operation | `number` | `60` | no |
| <a name="input_enable_firewall"></a> [enable\_firewall](#input\_enable\_firewall) | Enable firewall configuration | `bool` | `false` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | *Depends on* `enable_firewall=true`. Firewall rules for the instance | `map(object({ description = string, ip = string, ports = list(string), services = list(string) }))` | `{}` | no |
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
| <a name="output_instance_host_internal"></a> [instance\_host\_internal](#output\_instance\_host\_internal) | Internal host of the CloudAMQP instance (**Sensitive**) |
| <a name="output_instance_vhost_dedicated"></a> [instance\_vhost\_dedicated](#output\_instance\_vhost\_dedicated) | Dedicated virtual host of the CloudAMQP instance |
| <a name="output_instance_dedicated"></a> [instance\_dedicated](#output\_instance\_dedicated) | Whether the instance is dedicated or shared |
| <a name="output_instance_backend"></a> [instance\_backend](#output\_instance\_backend) | Backend type of the CloudAMQP instance |


## Example 1: tfvars

```hcl
cloudamqp_instance = {

  plan        = "your-plan"
  region      = "your-region"
  nodes       = 1
  rmq_version = "4.0.4"
  vpc_id      = "your-vpc-id"
  tags        = ["production", "messaging"]
  }
cloudamqp_vpc_connect = {
  instance_id            = 123456
  region                 = "azure-arm::eastus"
  approved_subscriptions = ["xxxxxx-xxxx-xxxx-xxxxxxx", "xxxxxx-xxxx-xxxx-xxxxxxx"]
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
    type              = "memory"
    enabled           = true
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
    name               = "azure-log-analytics"
    api_key            = "your-azure-api-key"
    region             = "us-east-1"
    tags               = { environment = "production" }
    tenant_id          = "your-tenant-id"
    application_id     = "your-application-id"
    application_secret = "your-application-secret"
    dce_uri            = "https://example.com"
    table              = "logs"
    dcr_id             = "your-dcr-id"
  }
}
```

## Example 2: yaml

```yaml
kind: YourKind
lifecycle: production
name: name-of-your-instance
system: 'your-system'
version: '1.0'
providers:
  terraform:
    tfStateKey: xxxxxx-xxxx-xxxx-xxxxxx
    name: name-of-your-instace
    source: remote
    module: git::https://github.com/prefapp/tfm.git//modules/cloudamqp-cluster?ref=example-version
    values:
      cloudamqp_instance:
        plan: "your-plan"
        region: "your-region"
        nodes: 1
        rmq_version: "4.0.4"
        vpc_id: "your-vpc-id"
        tags:
          - "production"
          - "messaging"
      cloudamqp_vpc_connect:
        instance_id: 123456
        region: "azure-arm::eastus"
        approved_subcriptions:
          - "xxxxxx-xxxx-xxxx-xxxxxxx"
          - "xxxxxx-xxxx-xxxx-xxxxxxx"
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
