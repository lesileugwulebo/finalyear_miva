output "resource_group_name" {
  value       = azurerm_resource_group.terraform_state.name
  description = "Name of the resource group hosting Terraform remote state."
}

output "storage_account_name" {
  value       = azurerm_storage_account.terraform_state.name
  description = "Name of the Azure Storage Account holding remote state blobs."
}

output "container_name" {
  value       = azurerm_storage_container.terraform_state.name
  description = "Name of the private Blob Container storing state files."
}
