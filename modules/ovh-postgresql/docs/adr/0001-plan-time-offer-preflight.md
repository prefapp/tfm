# Plan-Time Offer Preflight

OVH's Terraform provider does not expose the database availability catalogue as a plan-time data source, so this module uses a read-only Python 3 standard-library helper through `hashicorp/external`. The runner must supply the same regional OVH identity to both processes through environment variables; this keeps the implementation within the existing module while accepting explicit runtime and portability costs, and mock tests cannot establish endpoint-specific authentication compatibility.
