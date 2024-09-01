variable "deploy_id" {
  description = "Domino deployment id"
  type        = string
  nullable    = false
}

variable "oidc_issuer_url" {
  description = "OIDC issuer url"
  type        = string
  nullable    = false
}

variable "resource_group_location" {
  description = "Resource group location"
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  nullable    = false
}

### Variables with default values ###

variable "namespaces" {
  description = "Namespaces for workload identity federation"
  type = object({
    compute  = optional(string, "domino-compute")
    platform = optional(string, "domino-platform")
  })
  default = {}
}

variable "service_account_names" {
  description = "Service account names for workload identity federation"
  type = object({
    datacatalog    = optional(string, "datacatalog")
    flyteadmin     = optional(string, "flyteadmin")
    flytepropeller = optional(string, "flytepropeller")
    nucleus        = optional(string, "nucleus")
  })
  default = {}
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "private_cluster_enabled" {
  description = "Flag to determine whether to deploy a private cluster"
  type        = bool
  default     = false
}
variable "aks_vnet_name" {
  description = "VNet name for ACR/AKS, required when either private_acr_enabled or private_cluster_enabled is set to true."
  type        = string
  default     = null
}

variable "aks_subnet_name" {
  description = "Subnet name for ACR/AKS, required when either private_acr_enabled or private_cluster_enabled is set to true."
  type        = string
  default     = null
}

variable "aks_vnet_rg_name" {
  description = "VNet Resource Groupe name for ACR/AKS, required when either private_acr_enabled or private_cluster_enabled is set to true."
  type        = string
  default     = null
}
