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
    access_key_id     = "process.env.AWS_ACCESS_KEY_ID"
    secret_access_key = "process.env.AWS_SECRET_ACCESS_KEY"
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
    access_key_id      = "process.env.AWS_ACCESS_KEY_ID"
    secret_access_key  = "process.env.AWS_SECRET_ACCESS_KEY"
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



