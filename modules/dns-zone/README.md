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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.45 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.45 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |
| [azurerm_federated_identity_credential.cert_manager](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_federated_identity_credential.external_dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_role_assignment.cert_manager](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.external_dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.cert_manager](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.external_dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_manager_create"></a> [cert\_manager\_create](#input\_cert\_manager\_create) | Create the cert-manager UAMI, DNS Zone Contributor assignment, and federated credential. | `bool` | `false` | no |
| <a name="input_cert_manager_service_account"></a> [cert\_manager\_service\_account](#input\_cert\_manager\_service\_account) | Kubernetes ServiceAccount name for cert-manager controller. Must match the SA created<br/>by the cert-manager helm release running in `namespaces.platform` — otherwise the<br/>federated identity credential subject and the pod's projected token won't align and<br/>AAD token exchange fails with AADSTS700213. | `string` | `"cert-manager"` | no |
| <a name="input_deploy_id"></a> [deploy\_id](#input\_deploy\_id) | Domino deployment ID — used as a name prefix for managed identities. | `string` | n/a | yes |
| <a name="input_external_dns_create"></a> [external\_dns\_create](#input\_external\_dns\_create) | Create the external-dns UAMI, DNS Zone Contributor assignment, and federated credential. | `bool` | `false` | no |
| <a name="input_external_dns_service_account"></a> [external\_dns\_service\_account](#input\_external\_dns\_service\_account) | Kubernetes ServiceAccount name for external-dns. | `string` | `"external-dns"` | no |
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | Kubernetes namespace names used to build FIC subjects. | `object({ platform = string })` | n/a | yes |
| <a name="input_oidc_issuer_url"></a> [oidc\_issuer\_url](#input\_oidc\_issuer\_url) | OIDC issuer URL from the AKS cluster — used for federated identity credentials. | `string` | n/a | yes |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | Azure region of the resource group. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group in which to create the DNS zone and identities. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | FQDN of the Azure DNS zone to create. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cert_manager_identity"></a> [cert\_manager\_identity](#output\_cert\_manager\_identity) | Workload identity for cert-manager (null when cert\_manager\_create=false). |
| <a name="output_external_dns_identity"></a> [external\_dns\_identity](#output\_external\_dns\_identity) | Workload identity for external-dns (null when external\_dns\_create=false). |
| <a name="output_zone"></a> [zone](#output\_zone) | DNS zone details. |
<!-- END_TF_DOCS -->
