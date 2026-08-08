output "entra_cloud_admins_group_id" {
  value = azuread_group.cloud_admins.object_id
}

output "entra_network_admins_group_id" {
  value = azuread_group.network_admins.object_id
}

output "entra_security_auditors_group_id" {
  value = azuread_group.security_auditors.object_id
}
