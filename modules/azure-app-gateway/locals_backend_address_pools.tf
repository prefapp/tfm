locals {

    # Flatten the backend_address_pools into a list of objects
    
    backend_address_pools = flatten([
        
        for tenant_key, tenant_value in var.application_gateway.blocks : [
            
            for service_key, service_value in tenant_value : [
                
                for env_key, env_value in service_value : [

                    merge(
                        
                        # This are the special default values for the probes
                        {
                            name = "backend_address_pool-${tenant_key}_${service_key}_${env_key}"
                        },
                        
                        # This are the default values for the probes
                        lookup(local.blocks_defaults, "backend_address_pool", {}),

                        # It will be overwritten by the values from the service/env
                        env_value.backend_address_pool,

                    )
                ]
            ]
        ]
    ])
}
       
