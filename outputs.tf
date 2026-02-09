output "containers" {
  description = "storage details"
  value       = azurerm_storage_container.domino_containers
}

output "storage_account" {
  description = "storage account"
  value       = azurerm_storage_account.domino
}

output "shared_storage_account" {
  description = "shared storage account"
  value       = azurerm_storage_account.domino_shared
}

output "aks_identity" {
  description = "AKS managed identity"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0]
}

output "oidc_issuer_url" {
  description = "OIDC issuer url"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "domino_acr" {
  description = "Azure Container Registry details"
  value       = azurerm_container_registry.domino
}

output "workload_identities" {
  description = "service identities"
  value = {
    "hephaestus" = azurerm_user_assigned_identity.hephaestus
  }
}
output "blob_dns_zone_name" {
  description = "blob dns zone name"
  value       = var.private_cluster_enabled ? azurerm_private_dns_zone.blob_private_dns_zone[0].name : null
}

output "private_cluster_enabled" {
  description = "Flag to determine if AKS is private or public"
  value       = var.private_cluster_enabled
}

#===============================================================================
# ACR Credential Refresher Output
# Provides configuration for Helm values to deploy the credential refresher.
# Note: The credential refresher CronJob should run immediately after deployment
# to generate initial credentials for workloads.
#===============================================================================
output "acr_credential_refresher" {
  description = "Configuration for ACR credential refresher Helm values. Only populated when enable_acr_credential_refresher is true."
  sensitive   = true
  value = var.enable_acr_credential_refresher ? {
    identity_client_id = azurerm_user_assigned_identity.acr_credential_refresher[0].client_id
    subscription_id    = data.azurerm_subscription.current.subscription_id
    resource_group     = data.azurerm_resource_group.aks.name
    registry_name      = azurerm_container_registry.domino.name
    registry_server    = azurerm_container_registry.domino.login_server
    token_name         = azurerm_container_registry_token.genai_model_pull[0].name
    token_username     = azurerm_container_registry_token.genai_model_pull[0].name
    service_account    = var.acr_credential_refresher_service_account
  } : null
}
