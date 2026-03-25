output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "grafana_url" {
  description = "Grafana dashboard URL (external)"
  value       = "https://${azurerm_container_app.grafana.ingress[0].fqdn}"
}

output "aca_environment_name" {
  description = "Azure Container Apps environment name"
  value       = azurerm_container_app_environment.main.name
}

output "aca_default_domain" {
  description = "ACA environment default domain for internal DNS"
  value       = azurerm_container_app_environment.main.default_domain
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.main.id
}
