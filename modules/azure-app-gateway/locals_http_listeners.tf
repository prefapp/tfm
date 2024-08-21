locals {

    http_listeners = flatten([
        
        for tenant_key, tenant_value in var.application_gateway.blocks : [
            
            for service_key, service_value in tenant_value : [
                
                for env_key, env_value in service_value : [

                     for listener_key, listener in env_value.http_listeners : [
                    
                        merge(
                            # This are the special default values for the probes
                            {
                                name= "listener-${tenant_key}_${service_key}_${env_key}-${listener_key}"
                            },

                            # This are the default values for the probes
                            lookup(local.blocks_defaults.http_listeners,listener_key, {}),

                            # It will be overwritten by the values from the service/env
                            env_value.http_listeners[listener_key]
                        )
                    ]

                ]
                                    
            ]
        ]
    ])

}
