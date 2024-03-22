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

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "deploy_id" {
  type        = string
  description = "Domino deployment ID"
  nullable    = false
}

variable "namespaces" {
  type = object({
    compute  = optional(string, "domino-compute")
    platform = optional(string, "domino-platform")
  })
  default     = {}
  description = "Namespaces for generating service account bindings"
}

variable "serviceaccount_names" {
  type = object({
    datacatalog    = optional(string, "datacatalog")
    flyteadmin     = optional(string, "flyteadmin")
    flytepropeller = optional(string, "flytepropeller")
    nucleus        = optional(string, "nucleus")
  })
  default     = {}
  description = "Service account names for workload identity federation"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}
