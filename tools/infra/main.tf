locals {
  location = "uksouth"
}

resource "azurerm_resource_group" "sat_rg" {
  name     = "sat-${var.environment}-${local.location}-rg"
  location = local.location
}


resource "azapi_resource" "container_apps_environment" {
  name      = "sat-${var.environment}-${local.location}-cae"
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  parent_id = azurerm_resource_group.sat_rg.id
  location  = local.location

  body = jsonencode({
    properties = {
      # appLogsConfiguration = {
      #   destination = "log-analytics"
      #   logAnalyticsConfiguration = {
      #     customerId = var.log_analytics_workspace_id
      #     sharedKey  = var.log_analytics_primary_shared_key
      #   }
      # }
      # vnetConfiguration = {
      #   internal               = true
      #   infrastructureSubnetId = var.subnet_id
      #   dockerBridgeCidr       = "10.2.0.1/16"
      #   platformReservedCidr   = "10.1.0.0/16"
      #   platformReservedDnsIP  = "10.1.0.2"
      # }
    }
  })
  ignore_missing_property = true
}
