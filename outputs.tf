output "containers" {
  description = "storage details (empty map when storage_create=false; safe for iteration and key-lookup — type stays map(storage_container) regardless of flag)"
  value       = azurerm_storage_container.domino_containers
}

output "storage_account" {
  description = "storage account"
  value       = var.storage_create ? azurerm_storage_account.domino[0] : null
}

output "shared_storage_account" {
  description = "shared storage account"
  value       = var.shared_storage_create ? azurerm_storage_account.domino_shared[0] : null
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
  value       = var.acr_create ? azurerm_container_registry.domino[0] : null
}

output "workload_identities" {
  description = "service identities (hephaestus null when hephaestus_create=false)"
  value = {
    hephaestus = var.hephaestus_create ? azurerm_user_assigned_identity.hephaestus[0] : null
  }
}
output "blob_dns_zone_name" {
  description = "blob dns zone name (null when private cluster or storage account is disabled)"
  value       = var.private_cluster_enabled && var.storage_create ? azurerm_private_dns_zone.blob_private_dns_zone[0].name : null
}

output "private_cluster_enabled" {
  description = "Flag to determine if AKS is private or public"
  value       = var.private_cluster_enabled
}

#===============================================================================
# ACR Credential Refresher Output
# Provides configuration for Helm values to deploy the credential refresher
#===============================================================================
output "acr_credential_refresher" {
  description = "Configuration for ACR credential refresher Helm values"
  value = var.acr_create ? {
    identity_client_id = azurerm_user_assigned_identity.acr_credential_refresher[0].client_id
    subscription_id    = data.azurerm_subscription.current.subscription_id
    resource_group     = data.azurerm_resource_group.aks.name
    registry_name      = azurerm_container_registry.domino[0].name
    registry_server    = azurerm_container_registry.domino[0].login_server
    token_name         = azurerm_container_registry_token.genai_model_pull[0].name
  } : null
}

output "dns_zone" {
  description = "DP Azure DNS zone details (null when dns_zone_create=false)"
  value       = try(module.dns_zone[0].zone, null)
}

output "external_dns_identity" {
  description = "Workload identity for external-dns (null when external_dns_create=false)"
  value       = try(module.dns_zone[0].external_dns_identity, null)
}

output "cert_manager_identity" {
  description = "Workload identity for cert-manager (null when cert_manager_create=false)"
  value       = try(module.dns_zone[0].cert_manager_identity, null)
}
