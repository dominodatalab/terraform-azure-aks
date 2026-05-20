# Coherence checks for the new DNS / identity flags. `terraform_data` runs preconditions
# at plan time without producing real resources. Using `precondition` (TF 1.2+) rather
# than cross-variable `validation` (TF 1.9+) so CI on TF 1.7.4 doesn't fail (see commit
# cb7dbd2 — `validation` blocks with multi-variable conditions were removed for that
# reason).
resource "terraform_data" "dns_zone_preconditions" {
  lifecycle {
    precondition {
      condition     = !var.dns_zone_create || length(var.dns_zone_name) > 0
      error_message = "dns_zone_name must be a non-empty FQDN when dns_zone_create=true."
    }
    precondition {
      condition     = !var.external_dns_create || var.dns_zone_create
      error_message = "external_dns_create=true requires dns_zone_create=true — the UAMI's DNS Zone Contributor role assignment needs a zone to scope to."
    }
    precondition {
      condition     = !var.cert_manager_create || var.dns_zone_create
      error_message = "cert_manager_create=true requires dns_zone_create=true — the UAMI's DNS Zone Contributor role assignment needs a zone to scope to."
    }
  }
}

module "dns_zone" {
  count  = var.dns_zone_create ? 1 : 0
  source = "./modules/dns-zone"

  zone_name               = var.dns_zone_name
  resource_group_name     = data.azurerm_resource_group.aks.name
  resource_group_location = data.azurerm_resource_group.aks.location
  tags                    = var.tags
  deploy_id               = var.deploy_id
  oidc_issuer_url         = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  namespaces              = var.namespaces

  external_dns_create          = var.external_dns_create
  external_dns_service_account = var.external_dns_service_account
  cert_manager_create          = var.cert_manager_create
  cert_manager_service_account = var.cert_manager_service_account
}
