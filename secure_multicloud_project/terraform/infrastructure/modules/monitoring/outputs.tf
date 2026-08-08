output "cloudwatch_application_log_group" {
  value = aws_cloudwatch_log_group.application.name
}

output "cloudwatch_vpc_flow_log_group" {
  value = aws_cloudwatch_log_group.vpc_flow.name
}

output "cloudtrail_bucket_name" {
  value = aws_s3_bucket.cloudtrail.id
}

output "azure_log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.main.name
}

output "azure_log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}
