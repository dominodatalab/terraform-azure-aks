#########################################################################
############################### Locals ##################################
#########################################################################
# locals for nodepools configuration
locals {
  node_pools = { for k, v in merge(var.node_pools, var.additional_node_pools) : k => v if k != "system" }
  zonal_node_pools = flatten([for name, spec in local.node_pools : [
    for zone in spec.zones :
    {
      node_pool_zone = zone
      node_pool_name = name
      node_pool_spec = spec
    }
    ]
  ])
}
#########################################################################
################################# Data ##################################
#########################################################################
# Retrieve kubernetes version
data "azurerm_kubernetes_service_versions" "selected" {
  location       = data.azurerm_resource_group.aks.location
  version_prefix = var.kubernetes_version
}
# Retrieve AKS subnet
data "azurerm_subnet" "aks_subnet" {
  count                = (var.private_acr_enabled || var.private_cluster_enabled) ? 1 : 0
  name                 = var.aks_subnet_name
  virtual_network_name = var.aks_vnet_name
  resource_group_name  = var.aks_vnet_rg_name
}
# Retrieve AKS vnet
data "azurerm_virtual_network" "aks_vnet" {
  count               = (var.private_acr_enabled || var.private_cluster_enabled) ? 1 : 0
  name                = var.aks_vnet_name
  resource_group_name = var.aks_vnet_rg_name
}
#########################################################################
########################### Private DNS Zone ############################
#########################################################################
# create private dns zone
resource "azurerm_private_dns_zone" "aks_private_dns_zone" {
  count               = var.private_cluster_enabled ? 1 : 0
  name                = "privatelink.${lower(replace(data.azurerm_resource_group.aks.location, " ", ""))}.azmk8s.io"
  resource_group_name = data.azurerm_resource_group.aks.name
}
# link the dns provate zone to the AKS VNET
resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_aks_vnet_link" {
  count                 = var.private_cluster_enabled ? 1 : 0
  name                  = "aks-vnet-dns-link"
  resource_group_name   = data.azurerm_resource_group.aks.name
  private_dns_zone_name = azurerm_private_dns_zone.aks_private_dns_zone[0].name
  virtual_network_id    = data.azurerm_virtual_network.aks_vnet[0].id
  depends_on = [
    azurerm_private_dns_zone.aks_private_dns_zone
  ]
}
#########################################################################
############################## AKS Cluster ##############################
#########################################################################
# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  lifecycle {
    ignore_changes = [
      tags,
      default_node_pool[0].node_count,
      default_node_pool[0].max_count,
      default_node_pool[0].tags,
      default_node_pool[0].upgrade_settings,
      # VM Size changes cause recreation of the entire cluster
      default_node_pool[0].vm_size
    ]
  }

  name                                = var.deploy_id
  location                            = data.azurerm_resource_group.aks.location
  resource_group_name                 = data.azurerm_resource_group.aks.name
  dns_prefix                          = var.private_cluster_enabled ? null : var.deploy_id
  private_cluster_enabled             = var.private_cluster_enabled
  sku_tier                            = var.cluster_sku_tier
  kubernetes_version                  = data.azurerm_kubernetes_service_versions.selected.latest_version
  role_based_access_control_enabled   = true
  dns_prefix_private_cluster          = var.private_cluster_enabled ? var.deploy_id : null
  private_dns_zone_id                 = var.private_cluster_enabled ? azurerm_private_dns_zone.aks_private_dns_zone[0].id : null
  private_cluster_public_fqdn_enabled = var.private_cluster_enabled ? var.private_cluster_public_fqdn_enabled : null

  dynamic "api_server_access_profile" {
    for_each = var.private_cluster_enabled ? [] : [1]
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  default_node_pool {
    name                         = "system"
    only_critical_addons_enabled = true
    enable_node_public_ip        = var.node_pools.system.enable_node_public_ip
    node_labels                  = var.node_pools.system.node_labels
    vm_size                      = var.node_pools.system.vm_size
    zones                        = var.node_pools.system.zones
    os_disk_size_gb              = var.node_pools.system.os_disk_size_gb
    enable_auto_scaling          = var.node_pools.system.enable_auto_scaling
    orchestrator_version         = data.azurerm_kubernetes_service_versions.selected.latest_version
    min_count                    = var.node_pools.system.min_count
    max_count                    = var.node_pools.system.max_count
    node_count                   = var.node_pools.system.initial_count
    max_pods                     = var.node_pools.system.max_pods
    tags                         = var.tags
    vnet_subnet_id               = (var.private_acr_enabled || var.private_cluster_enabled) ? data.azurerm_subnet.aks_subnet[0].id : null
  }
  identity {
    type         = var.private_cluster_enabled ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.private_cluster_enabled ? [azurerm_user_assigned_identity.aks_assigned_identity[0].id] : null
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
  }

  auto_scaler_profile {
    balance_similar_node_groups = true
  }

  network_profile {
    load_balancer_sku   = "standard"
    network_plugin      = "azure"
    network_policy      = "calico"
    network_plugin_mode = var.cni_overlay_enabled ? "overlay" : null
    dns_service_ip      = var.cni_overlay_enabled ? var.dns_service_ip : null
    service_cidr        = var.cni_overlay_enabled ? var.service_cidr : null
    pod_cidr            = var.cni_overlay_enabled ? var.pod_cidr : null

    outbound_type = var.kubernetes_nat_gateway == null ? "loadBalancer" : "managedNATGateway"

    dynamic "nat_gateway_profile" {
      for_each = var.kubernetes_nat_gateway == null ? [] : [var.kubernetes_nat_gateway]
      content {
        idle_timeout_in_minutes   = nat_gateway_profile.value.idle_timeout_in_minutes
        managed_outbound_ip_count = nat_gateway_profile.value.managed_outbound_ip_count
      }
    }
  }

  tags = var.tags

  provisioner "local-exec" {
    command = <<-EOF
      if ! az account show 2>/dev/null; then
        az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID
      fi

      az aks get-credentials --overwrite-existing -f ${var.kubeconfig_output_path} -n ${var.deploy_id} -g ${data.azurerm_resource_group.aks.name}
    EOF
  }
  depends_on = [
    azurerm_role_assignment.identity_assign_rg,
    azurerm_role_assignment.identity_assign_vnet
  ]
}

resource "azurerm_kubernetes_cluster_node_pool" "aks" {
  for_each = { for ng in local.zonal_node_pools : "${ng.node_pool_name}${ng.node_pool_zone}" => ng }

  enable_node_public_ip = each.value.node_pool_spec.enable_node_public_ip
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  name                  = each.key
  node_count            = each.value.node_pool_spec.initial_count
  vm_size               = each.value.node_pool_spec.vm_size
  zones                 = [each.value.node_pool_zone]
  os_disk_size_gb       = each.value.node_pool_spec.os_disk_size_gb
  os_type               = "Linux"
  os_sku                = each.value.node_pool_spec.node_os
  node_labels           = each.value.node_pool_spec.node_labels
  node_taints           = each.value.node_pool_spec.node_taints
  enable_auto_scaling   = each.value.node_pool_spec.enable_auto_scaling
  orchestrator_version  = azurerm_kubernetes_cluster.aks.kubernetes_version
  min_count             = each.value.node_pool_spec.min_count
  max_count             = each.value.node_pool_spec.max_count
  max_pods              = each.value.node_pool_spec.max_pods
  tags                  = var.tags
  vnet_subnet_id        = (var.private_acr_enabled || var.private_cluster_enabled) ? data.azurerm_subnet.aks_subnet[0].id : null

  lifecycle {
    ignore_changes = [node_count, max_count, tags]
  }
}
