locals {
  application_rules = [
    {
      name             = "allow-nginx"
      source_addresses = ["*"]
      protocols = [
        {
          port = 80
          type = "Http"
        }
      ]
      target_fqdns = [var.aks_loadbalancer_ip]
    }
  ]

  network_rules = [
    {
      name                  = "allow-all-outbound"
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
      protocols             = ["TCP", "UDP"]
    }
  ]

  nat_rules = [
    {
      name                  = "nginx-dnat"
      source_addresses      = ["*"]
      destination_addresses = [module.afw.azure_firewall_public_ip]
      destination_ports     = ["80"]
      protocols             = ["TCP"]
      translated_address    = var.aks_loadbalancer_ip
      translated_port       = "80"
    }
  ]
}