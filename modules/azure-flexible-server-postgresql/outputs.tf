output "id" {
    value = azurerm_postgresql_flexible_server.this.id
}

output "subnet_id" {
    value = azurerm_subnet.subnet.id
}

output "dns_private_zone_id" {
    value = azurerm_dns_private_zone.dns_private_zone.id
}
