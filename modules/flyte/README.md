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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_domino_flyte_ep"></a> [domino\_flyte\_ep](#module\_domino\_flyte\_ep) | ../private_endpoint | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_private_dns_a_record.flyte_a_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_role_assignment.flyte_data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.flyte_metadata_controlplane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.flyte_metadata_dataplane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.flyte_sas](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.flyte_data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.flyte_metadata](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.flyte_sas](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_storage_account.flyte](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.domino_flyte_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.flyte_data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_container.flyte_metadata](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_user_assigned_identity.flyte_controlplane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.flyte_dataplane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_private_dns_zone.blob_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_subnet.aks_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_subnet_name"></a> [aks\_subnet\_name](#input\_aks\_subnet\_name) | Subnet name for AKS, required when private\_cluster\_enabled is set to true. | `string` | `null` | no |
| <a name="input_aks_vnet_name"></a> [aks\_vnet\_name](#input\_aks\_vnet\_name) | VNet name for AAKS, required when private\_cluster\_enabled is set to true. | `string` | `null` | no |
| <a name="input_aks_vnet_rg_name"></a> [aks\_vnet\_rg\_name](#input\_aks\_vnet\_rg\_name) | VNet Resource Groupe name for AKS, required when private\_cluster\_enabled is set to true. | `string` | `null` | no |
| <a name="input_blob_dns_zone_name"></a> [blob\_dns\_zone\_name](#input\_blob\_dns\_zone\_name) | Blob DNS zone name for flyte record | `string` | `"privatelink.blob.core.windows.net"` | no |
| <a name="input_deploy_id"></a> [deploy\_id](#input\_deploy\_id) | Domino deployment id | `string` | n/a | yes |
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | Namespaces for workload identity federation | <pre>object({<br/>    compute  = optional(string, "domino-compute")<br/>    platform = optional(string, "domino-platform")<br/>  })</pre> | `{}` | no |
| <a name="input_oidc_issuer_url"></a> [oidc\_issuer\_url](#input\_oidc\_issuer\_url) | OIDC issuer url | `string` | n/a | yes |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | Flag to determine whether to deploy a private cluster | `bool` | `false` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | Resource group location | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_service_account_names"></a> [service\_account\_names](#input\_service\_account\_names) | Service account names for workload identity federation | <pre>object({<br/>    datacatalog    = optional(string, "datacatalog")<br/>    flyteadmin     = optional(string, "flyteadmin")<br/>    flytepropeller = optional(string, "flytepropeller")<br/>    nucleus        = optional(string, "nucleus")<br/>  })</pre> | `{}` | no |
| <a name="input_storage_account_replication_type"></a> [storage\_account\_replication\_type](#input\_storage\_account\_replication\_type) | Storage account replication type | `string` | `"LRS"` | no |
| <a name="input_storage_account_tier"></a> [storage\_account\_tier](#input\_storage\_account\_tier) | Storage account tier | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_controlplane_client_id"></a> [controlplane\_client\_id](#output\_controlplane\_client\_id) | Flyte controlplane client id |
| <a name="output_data_container_name"></a> [data\_container\_name](#output\_data\_container\_name) | Flyte data storage container name |
| <a name="output_dataplane_client_id"></a> [dataplane\_client\_id](#output\_dataplane\_client\_id) | Flyte dataplane client id |
| <a name="output_metadata_container_name"></a> [metadata\_container\_name](#output\_metadata\_container\_name) | Flyte metadata storage container name |
| <a name="output_storage_account_key"></a> [storage\_account\_key](#output\_storage\_account\_key) | Flyte storage account key |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Flyte storage account name |
<!-- END_TF_DOCS -->
