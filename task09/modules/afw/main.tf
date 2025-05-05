resource "azurerm_public_ip" "firewall_pip" {
  name                = local.public_ip_name
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = local.firewall_subnet_name
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_firewall" "afw" {
  name                = local.firewall_name
  location            = var.location
  resource_group_name = var.rg_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }
}

resource "azurerm_route_table" "afw_route_table" {
  name                = local.route_table_name
  location            = var.location
  resource_group_name = var.rg_name

  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.afw.ip_configuration[0].private_ip_address
  }
}


data "azurerm_public_ip" "firewall_pip" {
  name                = azurerm_public_ip.firewall_pip.name
  resource_group_name = var.rg_name
}

# resource "azurerm_route" "fwpip_to_internet" {
#   name                   = var.fwpip
#   resource_group_name    = var.rg_name
#   route_table_name       = azurerm_route_table.afw_route_table.name
#   address_prefix         = "${data.azurerm_public_ip.firewall_pip.ip_address}/32"  # Firewall Public IP
#   next_hop_type          = "Internet"
# }


resource "azurerm_subnet_route_table_association" "subnet_assoc" {
  subnet_id      = data.azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.afw_route_table.id
}

data "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rg_name
}

resource "azurerm_firewall_application_rule_collection" "app_rule" {
  name                = local.app_rule_name
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.rg_name
  priority            = 100
  action              = "Allow"

  dynamic "rule" {
    for_each = var.application_rules
    content {
      name             = rule.value.name
      source_addresses = rule.value.source_addresses

      dynamic "protocol" {
        for_each = rule.value.protocols
        content {
          port = protocol.value.port
          type = protocol.value.type
        }
      }

      target_fqdns = rule.value.target_fqdns
    }
  }
}

resource "azurerm_firewall_network_rule_collection" "net_rule" {
  name                = local.net_rule_name
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.rg_name
  priority            = 200
  action              = "Allow"

  dynamic "rule" {
    for_each = var.network_rules
    content {
      name                  = rule.value.name
      source_addresses      = rule.value.source_addresses
      destination_addresses = rule.value.destination_addresses
      destination_ports     = rule.value.destination_ports
      protocols             = rule.value.protocols
    }
  }
}

resource "azurerm_firewall_nat_rule_collection" "nat_rule" {
  name                = local.nat_rule_name
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.rg_name
  priority            = 300
  action              = "Dnat"

  dynamic "rule" {
    for_each = var.nat_rules
    content {
      name                  = rule.value.name
      source_addresses      = rule.value.source_addresses
      destination_addresses = rule.value.destination_addresses
      destination_ports     = rule.value.destination_ports
      protocols             = rule.value.protocols
      translated_address    = rule.value.translated_address
      translated_port       = rule.value.translated_port
    }
  }
}