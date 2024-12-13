# Firewall rules
resource "cloudamqp_security_firewall" "this" {
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
