terraform {
  required_version = ">= 1.4.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.9"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.13"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
  }
}

provider "azurerm" {
  partner_id = "31912fbf-f6dd-5176-bffb-0a01e8ac71f2"

  # azurerm 5.x defaults resource_provider_registrations to "none"; keep the 4.x behaviour
  resource_provider_registrations = "legacy"

  features {
    # azurerm 5.x defaults both to disabled; keep the 4.x behaviour
    enhanced_validation {
      locations          = true
      resource_providers = true
    }
  }
}

provider "azapi" {}
