# Async failure visibility via DLQ and alarms

When EventBridge triggers the Lambda asynchronously, failures after retries are routed to an SQS dead-letter queue with optional CloudWatch alarms. This pattern exists because async Lambda invocations silently drop events after retry exhaustion; without a DLQ, operators have no visibility into replication failures beyond CloudWatch Logs searches.
