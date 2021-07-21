output "containers" {
  value = azurerm_storage_container.domino_containers
}

output "kubeconfig" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "storage_account" {
  value = azurerm_storage_account.domino
}

output "aks_identity" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0]
}

output "domino_acr" {
  value = azurerm_container_registry.domino
}
