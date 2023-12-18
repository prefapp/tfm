output "unified_output" {
  value = <<-EOT

      #######################
      #### PEERING ORIGIN ###
      #######################

      Origin Virtual Network Name:      ${var.origin_virtual_network_name}
      Origin Resource Group Name:       ${var.origin_resource_group_name}
      Origin Name Peering:              ${var.origin_name_peering}

      #######################
      # PEERING DESTINATION #
      #######################

      Destination Virtual Network Name: ${var.destination_virtual_network_name}
      Destination Resource Group Name:  ${var.destination_resource_group_name}
      Destination Name Peering:         ${var.destination_name_peering}

  EOT
}
