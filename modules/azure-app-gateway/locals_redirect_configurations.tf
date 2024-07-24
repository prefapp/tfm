locals {

    redirect_configurations = flatten([
        
        for tenant_key, tenant_value in var.application_gateway.blocks : [
            
            for service_key, service_value in tenant_value : [
                
                for env_key, env_value in service_value : [
                    
                    merge(
                        # This are the special default values for the probes
                        {
                            name = "redirect-${tenant_key}_${service_key}_${env_key}"
                            
                            target_listener_name = "listener-${tenant_key}_${service_key}_${env_key}-https"
                        },

                        # This are the default values for the probes
                        local.blocks_defaults.redirect_configuration,

                        # It will be overwritten by the values from the service/env
                        env_value.redirect_configuration,
                    )
                ]
            ]
        ]
    ])
}





