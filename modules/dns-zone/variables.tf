variable "zone_name" {
  description = "FQDN of the Azure DNS zone to create."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the DNS zone and identities."
  type        = string
}

variable "resource_group_location" {
  description = "Azure region of the resource group."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "deploy_id" {
  description = "Domino deployment ID — used as a name prefix for managed identities."
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL from the AKS cluster — used for federated identity credentials."
  type        = string
}

variable "namespaces" {
  description = "Kubernetes namespace names used to build FIC subjects."
  type        = object({ platform = string })
}

variable "external_dns_create" {
  description = "Create the external-dns UAMI, DNS Zone Contributor assignment, and federated credential."
  type        = bool
  default     = false
}

variable "external_dns_service_account" {
  description = "Kubernetes ServiceAccount name for external-dns."
  type        = string
  default     = "external-dns"
}

variable "cert_manager_create" {
  description = "Create the cert-manager UAMI, DNS Zone Contributor assignment, and federated credential."
  type        = bool
  default     = false
}

variable "cert_manager_service_account" {
  description = <<-EOT
    Kubernetes ServiceAccount name for cert-manager controller. Must match the SA created
    by the cert-manager helm release running in `namespaces.platform` — otherwise the
    federated identity credential subject and the pod's projected token won't align and
    AAD token exchange fails with AADSTS700213.
  EOT
  type        = string
  default     = "cert-manager"
}
