# Load YAML data from a file
data "local_file" "input" {
  filename = "${path.module}/input.yaml"
}
