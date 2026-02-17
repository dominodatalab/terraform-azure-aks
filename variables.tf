variable "api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "The IP ranges to whitelist for incoming traffic to the masters"
  default     = null
}

variable "resource_group" {
  type        = string
  description = "Name or id of optional pre-existing resource group to install AKS in"
}

variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID."
  nullable    = false

  validation {
    condition     = length(var.deploy_id) >= 3 && length(var.deploy_id) <= 24 && can(regex("^([a-z][-a-z0-9]*[a-z0-9])$", var.deploy_id))
    error_message = <<EOT
      Variable deploy_id must:
      1. Length must be between 3 and 24 characters.
      2. Start with a letter.
      3. End with a letter or digit.
      4. May contain lowercase Alphanumeric characters and hyphens.
    EOT
  }
}

variable "kubeconfig_output_path" {
  description = "kubeconfig path"
  type        = string
}

variable "cluster_sku_tier" {
  type        = string
  default     = null
  description = "The Domino cluster SKU (defaults to Free)"
}

variable "containers" {
  description = "storage containers to create"
  type = map(object({
    container_access_type = string
  }))

  default = {
    projects = {
      container_access_type = "private"
    }
    backups = {
      container_access_type = "private"
    }
  }
  validation {
    condition = alltrue([for k in keys(var.containers) :
      length(k) >= 3 &&
      length(k) <= 32 &&
      can(regex("^([a-z][-a-z0-9]*[a-z0-9])$", k))
    ])
    error_message = <<EOT
      Map containers keys must:
      1. Length must be between 3 and 32 characters.
      2. Start with a letter.
      3. End with a letter or digit.
      4. May contain lowercase Alphanumeric characters and hyphens.
    EOT
  }
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
variable "log_analytics_workspace_sku" {
  description = "log analytics sku"
  type        = string
  default     = "PerGB2018"
}

variable "node_pools" {
  description = "default node pools"
  type = object({
    compute = object({
      enable_node_public_ip = optional(bool, false)
      vm_size               = optional(string, "Standard_D8s_v4")
      zones                 = optional(list(string), ["1", "2", "3"])
      node_labels = optional(map(string), {
        "dominodatalab.com/node-pool" = "default"
      })
      node_os             = optional(string, "AzureLinux")
      node_taints         = optional(list(string), [])
      enable_auto_scaling = optional(bool, true)
      min_count           = optional(number, 0)
      max_count           = optional(number, 10)
      initial_count       = optional(number, 1)
      max_pods            = optional(number, 30)
      os_disk_size_gb     = optional(number, 128)
    }),
    platform = object({
      enable_node_public_ip = optional(bool, false)
      vm_size               = optional(string, "Standard_D8s_v4")
      zones                 = optional(list(string), ["1", "2", "3"])
      node_labels = optional(map(string), {
        "dominodatalab.com/node-pool" = "platform"
      })
      node_os             = optional(string, "AzureLinux")
      node_taints         = optional(list(string), [])
      enable_auto_scaling = optional(bool, true)
      min_count           = optional(number, 1)
      max_count           = optional(number, 3)
      initial_count       = optional(number, 1)
      max_pods            = optional(number, 60)
      os_disk_size_gb     = optional(number, 128)
    }),
    gpu = object({
      enable_node_public_ip = optional(bool, false)
      vm_size               = optional(string, "Standard_NC6s_v3")
      zones                 = optional(list(string), [])
      node_labels = optional(map(string), {
        "dominodatalab.com/node-pool" = "default-gpu"
        "nvidia.com/gpu"              = "true"
      })
      node_os = optional(string, "AzureLinux")
      node_taints = optional(list(string), [
        "nvidia.com/gpu=true:NoExecute"
      ])
      enable_auto_scaling = optional(bool, true)
      min_count           = optional(number, 0)
      max_count           = optional(number, 1)
      initial_count       = optional(number, 0)
      max_pods            = optional(number, 30)
      os_disk_size_gb     = optional(number, 128)
    })
    system = object({
      enable_node_public_ip = optional(bool, false)
      vm_size               = optional(string, "Standard_DS4_v2")
      zones                 = optional(list(string), ["1", "2", "3"])
      node_labels           = optional(map(string), {})
      node_os               = optional(string, "AzureLinux")
      node_taints           = optional(list(string), [])
      enable_auto_scaling   = optional(bool, true)
      min_count             = optional(number, 1)
      max_count             = optional(number, 6)
      initial_count         = optional(number, 1)
      max_pods              = optional(number, 60)
      os_disk_size_gb       = optional(number, 128)
    })
  })
  default = {
    compute  = {}
    platform = {}
    gpu      = {}
    system   = {}
  }
}

variable "additional_node_pools" {
  description = "additional node pools"
  type = map(object({
    enable_node_public_ip = optional(bool, false)
    vm_size               = string
    zones                 = list(string)
    node_labels           = map(string)
    node_os               = optional(string, "AzureLinux")
    node_taints           = optional(list(string), [])
    enable_auto_scaling   = optional(bool, true)
    min_count             = optional(number, 0)
    max_count             = number
    initial_count         = optional(number, 0)
    max_pods              = optional(number, 30)
    os_disk_size_gb       = optional(number, 128)
  }))
  default = {}
}

variable "storage_account_tier" {
  description = "storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "storage replication"
  type        = string
  default     = "LRS"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}

variable "kubernetes_version" {
  type        = string
  default     = null
  description = "Optional Kubernetes version to provision. Allows partial input (e.g. 1.18) which is then chosen from azurerm_kubernetes_service_versions."
}

variable "registry_tier" {
  description = "registry tier"
  type        = string
  default     = "Standard"
}

variable "namespaces" {
  type        = object({ platform = string, compute = string })
  description = "Namespace that are used for generating the service account bindings"
}

variable "kubernetes_nat_gateway" {
  type = object({
    idle_timeout_in_minutes   = optional(number, 4)
    managed_outbound_ip_count = number
    }
  )
  default     = null
  nullable    = true
  description = "Managed NAT Gateway configuration"
}

variable "cni_overlay_enabled" {
  description = "Flag to determine whether to use overlay network settings"
  type        = bool
  default     = false
}

variable "dns_service_ip" {
  description = "IP address assigned to the Kubernetes DNS service, used when CNI Overlay is enabled"
  type        = string
  default     = "100.97.0.10"
}

variable "service_cidr" {
  description = "CIDR block for Kubernetes services, used  when CNI Overlay is enabled"
  type        = string
  default     = "100.97.0.0/16"
}

variable "pod_cidr" {
  description = "CIDR block for Kubernetes pods, used when CNI Overlay is enabled"
  type        = string
  default     = "192.168.0.0/16"
}

variable "private_acr_enabled" {
  description = "Flag to determine whether to deploy a private ACR"
  type        = bool
  default     = false
}

variable "private_cluster_enabled" {
  description = "Flag to determine whether to deploy a private AKS"
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

variable "private_cluster_public_fqdn_enabled" {
  description = "Flag to determine whether to use a public FQDN when deploying a private AKS cluster"
  type        = bool
  default     = null
}

variable "node_os_upgrade_channel" {
  description = "Option to enable automatic node OS upgrades.  Possible values are Unmanaged, SecurityPatch, NodeImage and None."
  type        = string
  default     = "None"
}

variable "acr_genai_model_repository" {
  description = "Repository path for Gen AI models in ACR. Used for repository-scoped token permissions."
  type        = string
  default     = "dominodatalab/genai-model"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$", var.acr_genai_model_repository))
    error_message = "Repository path must be namespace/repo and match the path used by Nucleus."
  }
}

variable "acr_credential_refresher_service_account" {
  description = "Kubernetes ServiceAccount name for the ACR credential refresher (must match nucleus chart: release-fullname + '-acr-credential-refresher')."
  type        = string
  default     = "nucleus-acr-credential-refresher"
}

variable "workspace_audit" {
  description = "Workspace audit configuration"
  type = object({
    enabled                       = optional(bool, false)
    events_container_name         = optional(string, "workspace-audit-events-working")
    events_archive_container_name = optional(string, "workspace-audit-events-archive")
    container_access_type         = optional(string, "private")
  })
  default = {}
}
