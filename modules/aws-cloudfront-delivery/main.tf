resource "random_id" "oac_suffix" {
  byte_length = 4
  # This random suffix is used to ensure the default OAC name is unique per deployment
}
