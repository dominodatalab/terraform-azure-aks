output "kubeconfig" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

# TODO: Make it possible to input so we don't have to round-trip this
output "resource_group" {
  value = azurerm_resource_group.k8s
}
