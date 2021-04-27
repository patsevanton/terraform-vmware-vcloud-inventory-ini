terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "3.0.0"
    }
  }
}

# Configure the VMware vCloud Director Provider
provider "vcd" {
  user                 = var.vcd_org_user
  password             = var.vcd_org_password
  auth_type            = "integrated"
  org                  = var.vcd_org_org
  vdc                  = var.vcd_org_vdc
  url                  = var.vcd_org_url
  max_retry_timeout    = 30
  allow_unverified_ssl = true
}

# Create routed org-network
resource "vcd_network_routed" "MyAppNet" {
  name = "MyAppNet"
  edge_gateway = var.vcd_org_edge_name
  gateway = "10.1.0.1"
  dhcp_pool {
    start_address = "10.1.0.15"
    end_address = "10.1.0.20"
  }
}

# vApp Name and Metadata
resource "vcd_vapp" "MyApp" {
  name = "MyApp"
  power_on = "true"
}

# vApp network connected to routed org-network
resource "vcd_vapp_org_network" "MyAppNet" {
  vapp_name = "MyApp"
  org_network_name = vcd_network_routed.MyAppNet.name
}

resource "vcd_vapp_vm" "WebServer" {
  vapp_name = vcd_vapp.MyApp.name
  name = "WebServer"
  catalog_name  = var.vcd_org_catalog
  template_name = var.template_vm
  memory = 512
  cpus       = 2
  cpu_cores  = 2

  network {
    type = "org"
    name = vcd_network_routed.MyAppNet.name
    ip_allocation_mode = "DHCP"
  }
  depends_on = [vcd_vapp.MyApp]
}
