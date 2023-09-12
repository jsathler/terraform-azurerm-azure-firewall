locals {
  location     = "northeurope"
  local_subnet = "10.0.0.0/16"
  adds_servers = ["10.0.0.4", "10.0.0.5"]
  dns_servers  = local.adds_servers
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "firewall-example-rg"
  location = local.location
}

resource "azurerm_public_ip_prefix" "default" {
  name                = "example-pippf"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  prefix_length       = 31
  zones               = [1, 2, 3]
}

module "hub-vnet" {
  source              = "../../../vnet"
  name                = "hub"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = [local.local_subnet]
  dns_servers         = local.dns_servers

  subnets = {
    AzureFirewallSubnet = {
      address_prefixes   = [cidrsubnet(local.local_subnet, 10, 0)]
      nsg_create_default = false
    }
    AzureFirewallManagementSubnet = {
      address_prefixes   = [cidrsubnet(local.local_subnet, 10, 1)]
      nsg_create_default = false
    }
  }
}

module "firewall-policy" {
  source              = "../../../firewall-policy"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  firewall_policy = {
    name = "example"
  }
}

module "azure-firewall" {
  source              = "../../"
  name                = "example"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  firewall_policy_id  = module.firewall-policy.policy_id

  networking = {
    subnet_id           = module.hub-vnet.subnet_ids.AzureFirewallSubnet
    public_ip_count     = 0
    public_ip_prefix_id = azurerm_public_ip_prefix.default.id
  }

  managed_networking = {
    subnet_id           = module.hub-vnet.subnet_ids.AzureFirewallManagementSubnet
    public_ip_prefix_id = azurerm_public_ip_prefix.default.id
  }
}
