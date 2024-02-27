variable "azurerm_container_registry" {
  type = object({
    domino = object({
      id = string
    })
  })
}

variable "azurerm_kubernetes_cluster" {
  type = object({
    aks = object({
      name = string
      oidc_issuer_url = string
    })
  })
}

variable "azurerm_resource_group" {
  type = object({
    aks = object({
      location = string
      name     = string
    })
  })
}

variable "azurerm_storage_account" {
  type = object({
    domino = object({
      name = string
    })
  })
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
  description = "Namespace that are used for generating the service account bindings"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}
