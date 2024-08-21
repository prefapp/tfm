 # Flatten the probes into a list of objects

locals {

    probes = flatten([
        
        for tenant_key, tenant_value in var.application_gateway.blocks : [
            
            for service_key, service_value in tenant_value : [
                
                for env_key, env_value in service_value : [
                    
                    merge(
                        # This are the special default values for the probes
                        {
                            name = "probe-${tenant_key}-${service_key}-${env_key}"
                        },

                        # This are the default values for the probes
                        local.blocks_defaults.probe,

                        # It will be overwritten by the values from the service/env
                        env_value.probe,
                    )
                ]
            ]
        ]
    ])
}
