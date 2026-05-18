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
