locals {
  tags = merge(var.tags, { ManagedByTerraform = "True" })

  # AzureFirewallSubnet requires a subnet id and a public ip. Public IP is optional IF AzureFirewallManagedSubnet is used
  networking = var.networking.public_ip_count == 0 ? {
    ipconfig-0 = {
      subnet_id = var.networking.subnet_id
      public_ip = false
    }
    } : { for key in range(0, var.networking.public_ip_count) : "ipconfig-${key}" => {
      subnet_id           = key == 0 ? var.networking.subnet_id : null
      public_ip           = true
      public_ip_prefix_id = var.networking.public_ip_prefix_id
    }
  }

  # AzureFirewallManagedSubnet requires a subnet id and a public IP
  management_networking = var.managed_networking == null ? {} : {
    mgmt-ipconfig-0 = {
      subnet_id           = var.managed_networking.subnet_id
      public_ip_prefix_id = var.managed_networking.public_ip_prefix_id
    }
  }
}

resource "azurerm_public_ip" "default" {
  for_each            = { for key, value in local.networking : key => value if value.public_ip }
  name                = "${var.name}-${each.key}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  public_ip_prefix_id = each.value.public_ip_prefix_id
  zones               = var.zones
  tags                = local.tags

  #This is an workarround since Terraform tries to delete the IP before dissasociate the IP from Azure Firewall
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_public_ip" "mgmt" {
  for_each            = { for key, value in local.management_networking : key => value }
  name                = "${var.name}-${each.key}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  public_ip_prefix_id = each.value.public_ip_prefix_id
  zones               = var.zones
  tags                = local.tags

  #This is an workarround since Terraform tries to delete the IP before dissasociate the IP from Azure Firewall
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_firewall" "default" {
  name                = "${var.name}-fw"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = var.firewall_policy_id
  zones               = var.zones
  tags                = local.tags

  # Always required, can have more than 1 block but only one with subnet_id
  dynamic "ip_configuration" {
    for_each = { for key, value in local.networking : key => value }
    content {
      name                 = ip_configuration.key
      subnet_id            = ip_configuration.value.subnet_id
      public_ip_address_id = ip_configuration.value.public_ip ? azurerm_public_ip.default[ip_configuration.key].id : null
    }
  }

  # Optional, can have only one. Requires ip_configuration block 
  dynamic "management_ip_configuration" {
    for_each = { for key, value in local.management_networking : key => value }
    content {
      name                 = management_ip_configuration.key
      subnet_id            = management_ip_configuration.value.subnet_id
      public_ip_address_id = azurerm_public_ip.mgmt[management_ip_configuration.key].id
    }
  }

  dynamic "virtual_hub" {
    for_each = var.virtual_hub != null ? [var.virtual_hub] : []
    content {
      virtual_hub_id  = virtual_hub.value.virtual_hub_id
      public_ip_count = virtual_hub.value.public_ip_count
    }
  }
}
