module "afw" {
  source              = "./modules/afw"
  unique_id           = coalesce(var.unique_id, "default-name")
  location            = var.location
  rg_name             = var.rg_name
  vnet_name           = var.vnet_name
  vnet_space          = var.vnet_space
  subnet_name         = var.subnet_name
  subnet_space        = var.subnet_space
  aks_loadbalancer_ip = var.aks_loadbalancer_ip
  fwpip = var.fwpip_to_internet

  application_rules = local.application_rules
  network_rules     = local.network_rules
  nat_rules         = local.nat_rules
}