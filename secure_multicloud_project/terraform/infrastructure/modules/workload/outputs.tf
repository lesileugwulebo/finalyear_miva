output "aws_web_private_ip" {
  value = aws_instance.web.private_ip
}

output "aws_app_private_ip" {
  value = aws_instance.application.private_ip
}

output "aws_db_private_ip" {
  value     = aws_instance.database.private_ip
  sensitive = true
}

output "aws_alb_dns_name" {
  value = aws_lb.web.dns_name
}

output "azure_service_private_ip" {
  value = azurerm_network_interface.azure_service.private_ip_address
}

output "kms_key_arn" {
  value = aws_kms_key.workload.arn
}

output "secrets_manager_arn" {
  value = aws_secretsmanager_secret.database.arn
}
