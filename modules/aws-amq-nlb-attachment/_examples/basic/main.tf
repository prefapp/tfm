module "mq_nlb_attachment" {
  source = "../../.."
  broker_private_ips = [
    "10.0.1.100",
    "10.0.2.101"
  ]
  target_group_arn = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/example-tg/abcdef1234567890"
}

