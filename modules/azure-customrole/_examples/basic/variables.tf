variable "subscription_id" {
  description = "Azure subscription ID. Example: terraform plan -var=\"subscription_id=$(az account show --query id -o tsv)\""
  type        = string
}
