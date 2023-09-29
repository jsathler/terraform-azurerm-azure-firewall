module "azure-firewall" {
  source              = "jsathler/azure-firewall/azurerm"
  name                = "azure-firewall"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  firewall_policy_id  = module.firewall-policy.policy_id

  networking = {
    subnet_id           = module.hub-vnet.subnet_ids.AzureFirewallSubnet
    public_ip_count     = 2
    public_ip_prefix_id = azurerm_public_ip_prefix.default.id
  }
}
