<!-- BEGIN_TF_DOCS -->
# Azure firewall Terraform module

Terraform module which creates Azure Firewall resources on Azure.

Supported Azure services:

* [Public IP](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses)
* [Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/overview)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.70.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.70.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_public_ip.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_policy_id"></a> [firewall\_policy\_id](#input\_firewall\_policy\_id) | The ID of the Firewall Policy applied to this Firewall. This parameter is required | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The region where the Azure Firewall will be created. This parameter is required | `string` | `"northeurope"` | no |
| <a name="input_managed_networking"></a> [managed\_networking](#input\_managed\_networking) | Networking parameters if you want a 'Azure Firewall forced tunneling'. Defaults to 'null'<br>  - subnet\_id:           (required) AzureFirewallManagementSubnet subnet ID where the firewall will be attached. <br>  - public\_ip\_prefix\_id: (optional) The Public IP Prefix ID if you want to have the public IP(s) created from it<br><br>  If you want to use this feature, consider adding '0.0.0.0/0' as your private ip ranges, otherwise all traffic leaving Azure firwall will be SNAT | <pre>object({<br>    subnet_id           = string<br>    public_ip_prefix_id = optional(string, null)<br>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Azure Firewall name. This parameter is required | `string` | n/a | yes |
| <a name="input_networking"></a> [networking](#input\_networking) | Networking parameters. This parameter is required<br>  - subnet\_id:           (required) 'AzureFirewallSubnet' subnet ID where the firewall will be attached.<br>  - public\_ip\_count:     (optional) Define how many Public IPs will be created and attached to this firewall. Defaults to 1<br>  - public\_ip\_prefix\_id: (optional) The Public IP Prefix ID if you want to have the public IP(s) created from it | <pre>object({<br>    subnet_id           = string<br>    public_ip_count     = optional(number, 1)<br>    public_ip_prefix_id = optional(string, null)<br>  })</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the Azure Firewall will be created. This parameter is required | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name of the Azure Firewall. Defaults to 'AZFW\_VNet' | `string` | `"AZFW_VNet"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | The SKU tier of the Azure Firewall. Defaults to 'Standard' | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to resources. This parameter is optional | `map(string)` | `null` | no |
| <a name="input_virtual_hub"></a> [virtual\_hub](#input\_virtual\_hub) | Allows you to create and attach this Azure Firewall in a Virtual HUB. Defaults to 'null'<br>  - virtual\_hub\_id:   (required) Specifies the ID of the Virtual Hub where the Firewall resides in<br>  - public\_ip\_count:  (Optional) Define how many Public IPs will be created and attached to this firewall. Defaults to 1 | <pre>object({<br>    virtual_hub_id  = string<br>    public_ip_count = optional(number, 1)<br>  })</pre> | `null` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Specifies the availability zones in which the Azure Firewall should be created. Defaults to '[1, 2, 3]' | `list(string)` | <pre>[<br>  1,<br>  2,<br>  3<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_id"></a> [firewall\_id](#output\_firewall\_id) | Azure Firewall ID |
| <a name="output_firewall_name"></a> [firewall\_name](#output\_firewall\_name) | Azure Firewall ID |
| <a name="output_management_subnet_ip"></a> [management\_subnet\_ip](#output\_management\_subnet\_ip) | Azure Firewall management public IP address |
| <a name="output_management_subnet_snet_id"></a> [management\_subnet\_snet\_id](#output\_management\_subnet\_snet\_id) | Azure Firewall management subnet ID |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | Azure Firewall policy ID |
| <a name="output_private_address"></a> [private\_address](#output\_private\_address) | Azure Firewall private IP |
| <a name="output_public_addresses"></a> [public\_addresses](#output\_public\_addresses) | Azure Firewall public IP address(es) |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | Azure Firewall SKU name |
| <a name="output_sku_tier"></a> [sku\_tier](#output\_sku\_tier) | Azure Firewall SKU tier |
| <a name="output_snet_id"></a> [snet\_id](#output\_snet\_id) | Azure Firewall private subnet ID |
| <a name="output_zones"></a> [zones](#output\_zones) | Azure Firewall SKU tier |

## Examples
```hcl
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
```
More examples in ./examples folder
<!-- END_TF_DOCS -->