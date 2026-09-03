# Unified Lambda for all replication modes

The module deploys a single Lambda function that handles EventBridge-triggered replication, manual single-parameter invocation, and full-sync mode — distinguished by event shape rather than separate functions. This reduces IAM duplication, simplifies packaging, and provides a single operational surface. The alternative (separate Lambdas per mode) was rejected because EventBridge, manual, and full-sync share nearly all replication logic; splitting them would mean maintaining three copies of the same code.
