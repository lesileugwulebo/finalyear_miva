# Microsoft Entra ID Security Groups for Workforce Roles
resource "azuread_group" "cloud_admins" {
  display_name     = "MC-Cloud-Admins"
  security_enabled = true
  mail_enabled     = false
  description      = "Multi-Cloud Infrastructure Administrators"
}

resource "azuread_group" "network_admins" {
  display_name     = "MC-Network-Admins"
  security_enabled = true
  mail_enabled     = false
  description      = "Network and Inter-Cloud VPN Administrators"
}

resource "azuread_group" "security_auditors" {
  display_name     = "MC-Security-Auditors"
  security_enabled = true
  mail_enabled     = false
  description      = "Read-Only Cloud Security Auditors"
}

# Azure Role Assignments to Entra ID Groups
resource "azurerm_role_assignment" "cloud_admins" {
  scope                = var.azure_resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.cloud_admins.object_id
}

resource "azurerm_role_assignment" "network_admins" {
  scope                = var.azure_resource_group_id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_group.network_admins.object_id
}

resource "azurerm_role_assignment" "security_auditors" {
  scope                = var.azure_resource_group_id
  role_definition_name = "Security Reader"
  principal_id         = azuread_group.security_auditors.object_id
}

# AWS SSO / IAM Identity Center Permission Sets Discovery
data "aws_ssoadmin_instances" "main" {}

locals {
  sso_instance_arn = try(tolist(data.aws_ssoadmin_instances.main.arns)[0], "")
}

resource "aws_ssoadmin_permission_set" "security_auditor" {
  count            = local.sso_instance_arn != "" ? 1 : 0
  name             = "MultiCloudSecurityAuditor"
  description      = "Read-Only Security Audit Access"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "security_auditor" {
  count              = local.sso_instance_arn != "" ? 1 : 0
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_auditor[0].arn
  managed_policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_ssoadmin_permission_set" "network_admin" {
  count            = local.sso_instance_arn != "" ? 1 : 0
  name             = "MultiCloudNetworkAdministrator"
  description      = "Restricted Network Administration Access"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT2H"
}
