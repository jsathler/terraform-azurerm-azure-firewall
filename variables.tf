variable "location" {
  description = "The region where the Azure Firewall will be created. This parameter is required"
  type        = string
  default     = "northeurope"
}

variable "resource_group_name" {
  description = "The name of the resource group in which the Azure Firewall will be created. This parameter is required"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources. This parameter is optional"
  type        = map(string)
  default     = null
}

variable "zones" {
  description = " Specifies the availability zones in which the Azure Firewall should be created. Defaults to '[1, 2, 3]'"
  type        = list(string)
  default     = [1, 2, 3]
}

variable "name" {
  description = "Azure Firewall name. This parameter is required"
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Azure Firewall. Defaults to 'AZFW_VNet'"
  type        = string
  default     = "AZFW_VNet"

  validation {
    condition     = contains(["AZFW_VNet", "AZFW_Hub"], var.sku_name)
    error_message = "sku possible values are AZFW_VNet and AZFW_Hub. Defaults to 'AZFW_VNet'"
  }
}

variable "sku_tier" {
  description = "The SKU tier of the Azure Firewall. Defaults to 'Standard'"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_tier)
    error_message = "sku possible values are Basic, Standard and Premium. Defaults to 'Standard'"
  }
}

variable "firewall_policy_id" {
  description = "The ID of the Firewall Policy applied to this Firewall. This parameter is required"
  type        = string
}

variable "networking" {
  description = <<DESCRIPTION
  Networking parameters. This parameter is required
  - subnet_id:           (required) 'AzureFirewallSubnet' subnet ID where the firewall will be attached.
  - public_ip_count:     (optional) Define how many Public IPs will be created and attached to this firewall. Defaults to 1
  - public_ip_prefix_id: (optional) The Public IP Prefix ID if you want to have the public IP(s) created from it  
  DESCRIPTION

  type = object({
    subnet_id           = string
    public_ip_count     = optional(number, 1)
    public_ip_prefix_id = optional(string, null)
  })
}

variable "managed_networking" {
  description = <<DESCRIPTION
  Networking parameters if you want a 'Azure Firewall forced tunneling'. Defaults to 'null'
  - subnet_id:           (required) AzureFirewallManagementSubnet subnet ID where the firewall will be attached. 
  - public_ip_prefix_id: (optional) The Public IP Prefix ID if you want to have the public IP(s) created from it
  
  If you want to use this feature, consider adding '0.0.0.0/0' as your private ip ranges, otherwise all traffic leaving Azure firwall will be SNAT
  DESCRIPTION

  type = object({
    subnet_id           = string
    public_ip_prefix_id = optional(string, null)
  })
  default = null
}

variable "virtual_hub" {
  description = <<DESCRIPTION
  Allows you to create and attach this Azure Firewall in a Virtual HUB. Defaults to 'null'
  - virtual_hub_id:   (required) Specifies the ID of the Virtual Hub where the Firewall resides in
  - public_ip_count:  (Optional) Define how many Public IPs will be created and attached to this firewall. Defaults to 1
  DESCRIPTION

  type = object({
    virtual_hub_id  = string
    public_ip_count = optional(number, 1)
  })
  default = null
}
