# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}


# Create a new Resource Group
resource "azurerm_resource_group" "group" {
  name     = "techchallenge-webapp-containers-demo"
  location = "australiaeast"
}

# Create an App Service Plan with Linux
resource "azurerm_app_service_plan" "appserviceplan" {
  name                = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name

  # Define Linux as Host OS
  kind = "Linux"

  # Choose size
  sku {
    tier = "Standard"
    size = "S1"
  }

  #properties {
      reserved = "true"
  #}

}

# Create an Azure Web App for Containers in that App Service Plan
resource "azurerm_app_service" "dockerapp" {
  name                = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

  # Configure Docker Image to load on start
  site_config {
    linux_fx_version = "DOCKER|servian/techchallengeapp:latest"
    always_on        = "true"
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_postgresql_server" "group" {
  name                = "postgresqldb21"
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladminun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.6"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "group" {
  name                = "app"
  resource_group_name = azurerm_resource_group.group.name
  server_name         = azurerm_postgresql_server.group.name
  charset             = "UTF8"
  collation           = "English_Australia.1252"
}