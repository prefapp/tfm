output "secret" {
  value = nonsensitive(random_password.password[0].result)
}
