
variable "service_principal_name" {}
variable "service_principal_secret" {}

variable "agent_count" {
  default = 3
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "The Domino cluster name for the K8s cluster and resource group"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "k8stest"
}

variable "location" {
  default = "West US 2"
}

variable "log_analytics_workspace_name" {
  default = "testLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable "log_analytics_workspace_location" {
  default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}

variable "node_pools" {
  type = map(object({
    vm_size                        = string
    zones                          = list(string)
    node_os                        = string
    taints                         = list(string)
    cluster_auto_scaling           = bool
    cluster_auto_scaling_min_count = number
    cluster_auto_scaling_max_count = number
  }))
  default = {
    compute = {
      vm_size                        = "Standard_DS2_v2"
      zones                          = ["1", "2", "3"]
      node_os                        = "Linux"
      taints                         = null
      cluster_auto_scaling           = true
      cluster_auto_scaling_min_count = 1
      cluster_auto_scaling_max_count = 4
    }
    gpu = {
      vm_size                        = "Standard_DS2_v2"
      zones                          = ["1", "2", "3"]
      node_os                        = "Linux"
      taints                         = null
      cluster_auto_scaling           = true
      cluster_auto_scaling_min_count = 1
      cluster_auto_scaling_max_count = 1
    }
    platform = {
      vm_size                        = "Standard_DS2_v2"
      zones                          = ["1", "2", "3"]
      node_os                        = "Linux"
      taints                         = null
      cluster_auto_scaling           = true
      cluster_auto_scaling_min_count = 1
      cluster_auto_scaling_max_count = 4
    }
  }
}

variable subscription_id {
  type        = string
  default     = "de806df8-4359-4802-b814-b8a7699cfaa5" # Domino Engineering Platform Dev
  description = "An existing Subscription ID to add the deployment"
}