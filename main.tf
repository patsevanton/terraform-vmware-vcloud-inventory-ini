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

# This resource will destroy (potentially immediately) after null_resource.next
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "150s"
}

### NETWORKING ###
# Create routed org-network
resource "vcd_network_routed" "MyAppNet" {
  name = "MyAppNet"
  edge_gateway = "patsev_EDGE"
  gateway = "10.1.0.1"
  dhcp_pool {
    start_address = "10.1.0.15"
    end_address = "10.1.0.20"

  }

}

### vApp and VMs ###
# vApp Name and Metadata
resource "vcd_vapp" "MyApp" {
  name = "MyApp"
  metadata = {
    TestCycle = "123-A"
  }

}

# vApp network connected to routed org-network
resource "vcd_vapp_org_network" "MyAppNet" {
  vapp_name = "MyApp"
  org_network_name = vcd_network_routed.MyAppNet.name

}

# vApp VM 1
resource "vcd_vapp_vm" "WebServer" {
  vapp_name = vcd_vapp.MyApp.name
  name = "WebServer"
  catalog_name  = var.vcd_org_catalog
  template_name = var.template_vm
  memory = 512
  cpus = 1

  network {
    type = "org"
    name = vcd_network_routed.MyAppNet.name
    ip_allocation_mode = "DHCP"
  }

}
