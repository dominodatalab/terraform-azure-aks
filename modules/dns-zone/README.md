# modules/dns-zone

Creates a public Azure DNS zone, and optionally the external-dns and cert-manager
workload identities (UAMI + DNS Zone Contributor + federated credential).

## Usage

```hcl
module "dns_zone" {
  source = "./modules/dns-zone"

  zone_name               = "dp01.cp.az.domino.tech"
  resource_group_name     = azurerm_resource_group.dp.name
  resource_group_location = azurerm_resource_group.dp.location
  tags                    = var.tags
  deploy_id               = var.deploy_id
  oidc_issuer_url         = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  namespaces              = { platform = "domino-platform" }

  external_dns_create = true
  cert_manager_create = true
}
```

Outputs: `zone`, `external_dns_identity`, `cert_manager_identity`.
Set `external_dns_create` or `cert_manager_create` to `false` to skip those identities;
the corresponding output returns `null`.
