output "firewall_name" {
  description = "Azure Firewall ID"
  value       = azurerm_firewall.default.name
}

output "firewall_id" {
  description = "Azure Firewall ID"
  value       = azurerm_firewall.default.id
}

output "policy_id" {
  description = "Azure Firewall policy ID"
  value       = azurerm_firewall.default.firewall_policy_id
}

output "sku_name" {
  description = "Azure Firewall SKU name"
  value       = azurerm_firewall.default.sku_name
}

output "sku_tier" {
  description = "Azure Firewall SKU tier"
  value       = azurerm_firewall.default.sku_tier
}

output "zones" {
  description = "Azure Firewall SKU tier"
  value       = azurerm_firewall.default.zones
}

output "private_address" {
  description = "Azure Firewall private IP"
  value       = azurerm_firewall.default.ip_configuration[0].private_ip_address
}

output "snet_id" {
  description = "Azure Firewall private subnet ID"
  value       = azurerm_firewall.default.ip_configuration[0].subnet_id
}

output "public_addresses" {
  description = "Azure Firewall public IP address(es)"
  value       = [for ip in azurerm_public_ip.default : ip.ip_address]
}

output "management_subnet_snet_id" {
  description = "Azure Firewall management subnet ID"
  value       = length(azurerm_firewall.default.management_ip_configuration) == 0 ? null : azurerm_firewall.default.management_ip_configuration[0].subnet_id
}

output "management_subnet_ip" {
  description = "Azure Firewall management public IP address"
  value       = length(azurerm_public_ip.mgmt) == 0 ? null : azurerm_public_ip.mgmt["mgmt-ipconfig-0"].ip_address
}
