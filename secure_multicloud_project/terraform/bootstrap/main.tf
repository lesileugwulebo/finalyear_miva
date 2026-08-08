resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "terraform_state" {
  name     = "rg-${var.project_name}-tfstate-${var.environment}"
  location = var.azure_location

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Purpose     = "Terraform Remote State"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_storage_account" "terraform_state" {
  name                     = "st${var.project_name}${var.environment}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.terraform_state.name
  location                 = azurerm_resource_group.terraform_state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 14
    }

    container_delete_retention_policy {
      days = 14
    }
  }

  tags = {
    Project        = var.project_name
    Environment    = var.environment
    Purpose        = "Terraform Remote State Storage"
    ManagedBy      = "Terraform"
    Classification = "Confidential"
  }
}

resource "azurerm_storage_container" "terraform_state" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.terraform_state.name
  container_access_type = "private"
}
