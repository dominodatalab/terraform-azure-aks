<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.flyte_controlplane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_federated_identity_credential.flyte_dataplane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_role_assignment.flyte_controlplane_acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.flyte_dataplane_acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_container.flyte_data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_container.flyte_metadata](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_user_assigned_identity.flyte_controlplane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.flyte_dataplane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azurerm_container_registry_id"></a> [azurerm\_container\_registry\_id](#input\_azurerm\_container\_registry\_id) | AzureRM Container Registry ID | `string` | n/a | yes |
| <a name="input_azurerm_kubernetes_cluster_oidc_issuer_url"></a> [azurerm\_kubernetes\_cluster\_oidc\_issuer\_url](#input\_azurerm\_kubernetes\_cluster\_oidc\_issuer\_url) | AzureRM Kubernetes Cluster OIDC issuer url | `string` | n/a | yes |
| <a name="input_azurerm_resource_group_location"></a> [azurerm\_resource\_group\_location](#input\_azurerm\_resource\_group\_location) | AzureRM Resource Group location | `string` | n/a | yes |
| <a name="input_azurerm_resource_group_name"></a> [azurerm\_resource\_group\_name](#input\_azurerm\_resource\_group\_name) | AzureRM Resource Group name | `string` | n/a | yes |
| <a name="input_azurerm_storage_account_name"></a> [azurerm\_storage\_account\_name](#input\_azurerm\_storage\_account\_name) | AzureRM Storage Account name | `string` | n/a | yes |
| <a name="input_deploy_id"></a> [deploy\_id](#input\_deploy\_id) | Domino deployment ID | `string` | n/a | yes |
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | Namespaces for generating service account bindings | <pre>object({<br>    compute  = string<br>    platform = string<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks"></a> [aks](#output\_aks) | Flyte AKS info<pre>{<br>    metadata_container_name = Metadata storage container name<br>    data_container_name = Data storage container name<br>    controlplane_client_id = Controlplane client id<br>    dataplane_client_id = Dataplane client id<br>  }</pre> |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
