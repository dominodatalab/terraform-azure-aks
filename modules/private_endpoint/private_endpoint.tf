resource "azurerm_private_endpoint" "ep_object" {
  name                          = var.private_endpoint_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.subnet_id
  custom_network_interface_name = var.nic_name

  tags = {
    Environment = var.private_endpoint_name
  }

  private_service_connection {
    name                           = "connection_to_hub"
    is_manual_connection           = false
    private_connection_resource_id = var.resource_id
    subresource_names              = [var.sub_resource]
  }

  private_dns_zone_group {
    name                 = var.private_DNS_zone
    private_dns_zone_ids = [var.private_DNS_zone_id]
  }

  lifecycle {
    ignore_changes = [subnet_id]
  }
}
