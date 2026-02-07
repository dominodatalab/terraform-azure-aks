#===============================================================================
# ACR Repository-Scoped Token for Gen AI Model Operations
#
# Provisions a repository-scoped token used for ACR authentication when pulling
# Gen AI models. The token has read-only access to the Gen AI model repository.
#
# Components:
# - Scope map and repository-scoped token (with dual passwords for rotation)
# - Custom role for ACR token password regeneration
#
# The acr-credential-refresher CronJob (deployed via Helm) rotates the token
# passwords periodically; Terraform creates the token and the identity that
# is allowed to regenerate its credentials.
#===============================================================================

# Scope map defining permissions for the genai-model repository
resource "azurerm_container_registry_scope_map" "genai_model_pull" {
  name                    = "${var.deploy_id}-genai-model-pull"
  container_registry_name = azurerm_container_registry.domino.name
  resource_group_name     = data.azurerm_resource_group.aks.name

  actions = [
    "repositories/${var.acr_genai_model_repository}/content/read",
    "repositories/${var.acr_genai_model_repository}/metadata/read"
  ]

  description = "Read-only access to ${var.acr_genai_model_repository} for Gen AI model operations"
}

# Repository-scoped token
resource "azurerm_container_registry_token" "genai_model_pull" {
  name                    = "${var.deploy_id}-genai-model-pull"
  container_registry_name = azurerm_container_registry.domino.name
  resource_group_name     = data.azurerm_resource_group.aks.name
  scope_map_id            = azurerm_container_registry_scope_map.genai_model_pull.id
  enabled                 = true
}

# Dual passwords allow zero-downtime rotation
resource "azurerm_container_registry_token_password" "genai_model_pull" {
  container_registry_token_id = azurerm_container_registry_token.genai_model_pull.id

  password1 {} # Primary - initial slot
  password2 {} # Secondary - enables grace period during rotation

  lifecycle {
    # Passwords are rotated by the acr-credential-refresher CronJob after initial creation
    ignore_changes = [password1, password2]
  }
}

# Custom role definition for ACR token password regeneration
resource "azurerm_role_definition" "acr_token_credential_generator" {
  name        = "${var.deploy_id}-acr-token-credential-generator"
  scope       = data.azurerm_subscription.current.id
  description = "Allows regenerating ACR repository-scoped token passwords. Used by the credential refresher CronJob for rotation."

  permissions {
    actions = [
      "Microsoft.ContainerRegistry/registries/tokens/read",
      "Microsoft.ContainerRegistry/registries/generateCredentials/action"
    ]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_container_registry.domino.id
  ]
}
