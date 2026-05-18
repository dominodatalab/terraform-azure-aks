resource "azurerm_dns_zone" "dp" {
  count               = var.dns_zone_create ? 1 : 0
  name                = var.dns_zone_name
  resource_group_name = data.azurerm_resource_group.aks.name
  tags                = var.tags

  lifecycle {
    precondition {
      condition     = !var.dns_zone_create || length(var.dns_zone_name) > 0
      error_message = "dns_zone_name must be set when dns_zone_create=true."
    }
  }
}
