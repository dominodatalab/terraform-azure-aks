output "kubeconfig" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "resource_group" {
  value = local.resource_group
}
