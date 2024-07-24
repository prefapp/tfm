locals {

    request_routing_rules = flatten([
        
        for tenant_key, tenant_value in var.application_gateway.blocks : [
            
            for service_key, service_value in tenant_value : [
                
                for env_key, env_value in service_value : [

                     for request_routing_rule_key, request_routing_rule in env_value.request_routing_rules : [
                    
                        merge(
                            # This are the special default values for the probes
                            {
                                name                       = "request_routing_rule-${tenant_key}_${service_key}_${env_key}"
                                
                                http_listener_name         = "listener-${tenant_key}_${service_key}_${env_key}-${request_routing_rule_key}" #listener-corpme_ovac-dev-https
                            },

                            # This are the default values for the probes
                            lookup(local.blocks_defaults.request_routing_rules, request_routing_rule_key ,{}),

                            # It will be overwritten by the values from the service/env
                            env_value.request_routing_rules[request_routing_rule_key]
                        )
                    ]

                ]
                                    
            ]
        ]
    ])

}
