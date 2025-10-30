output "cert_content_base64_external" {
    value = data.external.cert_content_base64
}
output "id" {
    value = azurerm_application_gateway.application_gateway.id
}
