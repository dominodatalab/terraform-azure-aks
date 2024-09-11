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
