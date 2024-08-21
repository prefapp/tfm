locals {

    # Flatten the backend_http_settings into a list of objects

    backend_http_settings = flatten([
        
        for tenant_key, tenant_value in var.application_gateway.blocks : [
            
            for service_key, service_value in tenant_value : [
                
                for env_key, env_value in service_value : [
                    
                    merge(

                        # This are the special default values for the backend_http_settings
                        {
                            name = "backend_http_settings-${tenant_key}_${service_key}_${env_key}"
                           
                            probe_name = "probe-${tenant_key}-${service_key}-${env_key}"
                        },

                        # This are the default values for the backend_http_settings
                        local.blocks_defaults.backend_http_settings,
                        
                        # It will be overwritten by the values from the service/env
                        env_value.backend_http_settings
                    )
                ]
            ]
        ]
    ])

}



                       