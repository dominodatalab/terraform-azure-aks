output "zone" {
  description = "DNS zone details."
  value = {
    name            = azurerm_dns_zone.this.name
    nameservers     = azurerm_dns_zone.this.name_servers
    resource_group  = var.resource_group_name
    subscription_id = data.azurerm_subscription.current.subscription_id
  }
}

output "external_dns_identity" {
  description = "Workload identity for external-dns (null when external_dns_create=false)."
  value = var.external_dns_create ? {
    client_id       = azurerm_user_assigned_identity.external_dns[0].client_id
    principal_id    = azurerm_user_assigned_identity.external_dns[0].principal_id
    resource_group  = var.resource_group_name
    subscription_id = data.azurerm_subscription.current.subscription_id
    tenant_id       = data.azurerm_subscription.current.tenant_id
  } : null
}

output "cert_manager_identity" {
  description = "Workload identity for cert-manager (null when cert_manager_create=false)."
  value = var.cert_manager_create ? {
    client_id       = azurerm_user_assigned_identity.cert_manager[0].client_id
    principal_id    = azurerm_user_assigned_identity.cert_manager[0].principal_id
    resource_group  = var.resource_group_name
    subscription_id = data.azurerm_subscription.current.subscription_id
    tenant_id       = data.azurerm_subscription.current.tenant_id
  } : null
}
