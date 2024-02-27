variable "azurerm_container_registry_id" {
  type        = string
  description = "AzureRM Container Registry ID"
}

variable "azurerm_kubernetes_cluster_oidc_issuer_url" {
  type        = string
  description = "AzureRM Kubernetes Cluster OIDC issuer url"
}

variable "azurerm_resource_group_location" {
  type        = string
  description = "AzureRM Resource Group location"
}

variable "azurerm_resource_group_name" {
  type        = string
  description = "AzureRM Resource Group name"
}

variable "azurerm_storage_account_name" {
  type        = string
  description = "AzureRM Storage Account name"
}

variable "deploy_id" {
  type        = string
  description = "Domino deployment ID"
  nullable    = false
}

variable "namespaces" {
  type = object({
    compute  = string
    platform = string
  })
  description = "Namespaces for generating service account bindings"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}
