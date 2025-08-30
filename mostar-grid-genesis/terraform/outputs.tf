output "api_gateway_url" {
  description = "The public-facing URL of the MoStar Grid's API Gateway."
  value       = "https://${google_api_gateway_gateway.gateway.default_hostname}"
}

output "soul_vault_connection_name" {
  description = "The connection name for the Cloud SQL instance (the Soul Vault)."
  value       = google_sql_database_instance.soul_vault.connection_name
}
