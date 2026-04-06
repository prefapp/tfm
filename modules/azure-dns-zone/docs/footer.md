## Complete Example with DNS Records

```hcl
module "dns_zone" {
  source              = "git::https://github.com/prefapp/tfm.git//modules/azure-dns-zone"
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"

  # A Records (IPv4)
  a_records = [
    {
      name    = "www"
      ttl     = 3600
      records = ["1.2.3.4"]
    },
    {
      name    = "api"
      ttl     = 3600
      records = ["1.2.3.4", "5.6.7.8"]
    }
  ]

  # AAAA Records (IPv6)
  aaaa_records = [
    {
      name    = "www"
      ttl     = 3600
      records = ["2001:0db8:85a3::8a2e:0370:7334"]
    }
  ]

  # CNAME Records
  cname_records = [
    {
      name   = "mail"
      record = "mail.external.com."
      ttl    = 3600
    }
  ]

  # MX Records (Mail Exchange)
  mx_records = [
    {
      name    = "@"
      ttl     = 3600
      records = [
        { preference = 10, exchange = "mx1.example.com." },
        { preference = 20, exchange = "mx2.example.com." }
      ]
    }
  ]

  # TXT Records (SPF, DKIM, DMARC)
  txt_records = [
    {
      name    = "@"
      ttl     = 3600
      records = [
        { value = "v=spf1 include:mailgun.org ~all" }
      ]
    },
    {
      name    = "_dmarc"
      ttl     = 3600
      records = [
        { value = "v=DMARC1; p=none; rua=mailto:admin@example.com" }
      ]
    }
  ]

  # NS Records (Nameservers)
  ns_records = [
    {
      name    = "customns"
      ttl     = 3600
      records = ["ns1.example.com.", "ns2.example.com."]
    }
  ]

  # CAA Records (Certificate Authority Authorization)
  caa_records = [
    {
      name    = "@"
      ttl     = 3600
      records = [
        { flags = 0, tag = "issue", value = "letsencrypt.org" },
        { flags = 0, tag = "issuewild", value = ";" }
      ]
    }
  ]

  # SRV Records (Service)
  srv_records = [
    {
      name    = "_sip._tcp"
      ttl     = 3600
      records = [
        { priority = 10, weight = 60, port = 5060, target = "sipserver.example.com." }
      ]
    }
  ]

  # PTR Records (Reverse DNS)
  ptr_records = [
    {
      name    = "1.0.0.127"
      ttl     = 3600
      records = ["localhost.example.com."]
    }
  ]
}
```

## Tag Management

By default, you can provide custom tags using the `tags` variable. If you set `tags_from_rg = true`, the module will merge the tags from the specified resource group with any extra tags you define in `tags`. This allows you to inherit tags from the resource group and add or override with your own.

**Example: Inherit and extend tags**

```hcl
module "dns_zone" {
  source              = "git::https://github.com/prefapp/tfm.git//modules/azure-dns-zone"
  dns_zone_name       = "example.com"
  resource_group_name = "my-rg"
  tags_from_rg        = true
  tags = {
    environment = "dev"
    owner       = "network-team"
  }
}
```

In this example, the final tags will be the union of the resource group's tags and the `tags` map above. If a key exists in both, the value from `tags` will take precedence.

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-dns-zone/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azure-dns-zone/_examples/basic) - Minimal configuration for a DNS zone with basic records

## External Resources

- **Azure DNS Zone**: [https://learn.microsoft.com/en-us/azure/dns/dns-overview](https://learn.microsoft.com/en-us/azure/dns/dns-overview)
- **Terraform Azure Provider - DNS Zone**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone)
- **Azure DNS Record Types**: [https://learn.microsoft.com/en-us/azure/dns/dns-zones-records](https://learn.microsoft.com/en-us/azure/dns/dns-zones-records)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
