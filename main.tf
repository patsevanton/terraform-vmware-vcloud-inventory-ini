terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "3.0.0"
    }
  }
}
# Настройка провайдера для подключения к vCloud Director
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

resource "vcd_vapp" "apatsev" {
  name     = "apatsev"
  power_on = "true"
}

resource "vcd_vapp_org_network" "vapp-network" {
  vapp_name        = vcd_vapp.apatsev.name
  org_network_name = "NET01"
}

resource "vcd_vapp_vm" "apatsev" {
  vapp_name     = vcd_vapp.apatsev.name
  name          = "apatsev"
  catalog_name  = var.vcd_org_catalog
  template_name = var.template_vm
  memory        = 512
  cpus          = 1
  cpu_cores     = 1

  # network {
  #   type               = "org"
  #   name               = vcd_vapp_org_network.vapp-network.org_network_name
  #   ip                 = "192.168.199.211"
  #   ip_allocation_mode = "MANUAL"

  # }

  network {
    type               = "org"
    name               = vcd_vapp_org_network.vapp-network.org_network_name
    ip                 = ""
    ip_allocation_mode = "POOL"
    is_primary         = true
  }

  customization {
    enabled                    = true
    allow_local_admin_password = true
    admin_password             = var.vm_password
    auto_generate_password     = false
  }

  depends_on = [vcd_vapp.apatsev]

}
