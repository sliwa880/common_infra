locals {
  location = "uksouth"
}

resource "azurerm_resource_group" "sat_rg" {
  name     = "sat-core-${var.environment}-${local.location}-rg"
  location = local.location
}

resource "azapi_resource" "acr" {
  type      = "Microsoft.ContainerRegistry/registries@2021-09-01"
  name      = "sat${var.environment}${local.location}acr"
  location  = local.location
  parent_id = azurerm_resource_group.sat_rg.id
  body = jsonencode({
    sku = {
      name = "Standard"
    }
    properties = {
      adminUserEnabled = false
    }
  })
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-aca-terraform"
  resource_group_name = azurerm_resource_group.sat_rg.name
  location            = local.location
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

resource "azapi_resource" "aca_env" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  parent_id = azurerm_resource_group.sat_rg.id
  location  = local.location
  name      = "sat-${var.environment}-${local.location}-cae"

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.law.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.law.primary_shared_key
        }
      }
    }
  })
}
