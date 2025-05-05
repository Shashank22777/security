locals {
  firewall_subnet_name = "AzureFirewallSubnet"
  firewall_name        = "${var.unique_id}-afw"
  public_ip_name       = "${var.unique_id}-afw-pip"
  route_table_name     = "${var.unique_id}-afw-rt"
  app_rule_name        = "${var.unique_id}-app-rule"
  net_rule_name        = "${var.unique_id}-net-rule"
  nat_rule_name        = "${var.unique_id}-nat-rule"
}