<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.45 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.45 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_group.flyte_data_access](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group.flyte_metadata_access](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azurerm_federated_identity_credential.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_role_assignment.flyte_data_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.flyte_metadata_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.flyte_storage_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_storage_container.flyte_data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_container.flyte_metadata](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azurerm_kubernetes_cluster_oidc_issuer_url"></a> [azurerm\_kubernetes\_cluster\_oidc\_issuer\_url](#input\_azurerm\_kubernetes\_cluster\_oidc\_issuer\_url) | AzureRM Kubernetes Cluster OIDC issuer url | `string` | n/a | yes |
| <a name="input_azurerm_resource_group_location"></a> [azurerm\_resource\_group\_location](#input\_azurerm\_resource\_group\_location) | AzureRM Resource Group location | `string` | n/a | yes |
| <a name="input_azurerm_resource_group_name"></a> [azurerm\_resource\_group\_name](#input\_azurerm\_resource\_group\_name) | AzureRM Resource Group name | `string` | n/a | yes |
| <a name="input_azurerm_storage_account_name"></a> [azurerm\_storage\_account\_name](#input\_azurerm\_storage\_account\_name) | AzureRM Storage Account name | `string` | n/a | yes |
| <a name="input_deploy_id"></a> [deploy\_id](#input\_deploy\_id) | Domino deployment ID | `string` | n/a | yes |
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | Namespaces for generating service account bindings | <pre>object({<br>    compute  = optional(string, "domino-compute")<br>    platform = optional(string, "domino-platform")<br>  })</pre> | `{}` | no |
| <a name="input_serviceaccount_names"></a> [serviceaccount\_names](#input\_serviceaccount\_names) | Service account names for Flyte | <pre>object({<br>    datacatalog    = optional(string, "datacatalog")<br>    flyteadmin     = optional(string, "flyteadmin")<br>    flytepropeller = optional(string, "flytepropeller")<br>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_controlplane_client_id"></a> [controlplane\_client\_id](#output\_controlplane\_client\_id) | Flyte controlplane client id |
| <a name="output_data_container_name"></a> [data\_container\_name](#output\_data\_container\_name) | Flyte data storage container name |
| <a name="output_dataplane_client_id"></a> [dataplane\_client\_id](#output\_dataplane\_client\_id) | Flyte dataplane client id |
| <a name="output_metadata_container_name"></a> [metadata\_container\_name](#output\_metadata\_container\_name) | Flyte metadata storage container name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
