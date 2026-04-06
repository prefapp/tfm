# Basic Example

This example demonstrates how to create an Azure DNS zone with basic DNS records including A, MX, and TXT records.

## Example

```hcl
module "dns_zone" {
  source              = "../.."
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"

  # A Records
  a_records = [
    {
      name    = "www"
      ttl     = 3600
      records = ["1.2.3.4"]
    }
  ]

  # MX Records
  mx_records = [
    {
      name    = "@"
      ttl     = 3600
      records = [
        { preference = 10, exchange = "mx1.example.com." }
      ]
    }
  ]

  # TXT Records (SPF)
  txt_records = [
    {
      name    = "@"
      ttl     = 3600
      records = [
        { value = "v=spf1 include:mailgun.org ~all" }
      ]
    }
  ]

  tags = {
    environment = "production"
    managed-by  = "terraform"
  }
}
```

This example creates:
- A DNS zone named `example.com`
- An A record pointing `www` to IP `1.2.3.4`
- An MX record with mail server configuration
- A TXT record with SPF policy
