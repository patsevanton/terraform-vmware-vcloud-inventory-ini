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

# Создание маршрутизируемой сети
resource "vcd_network_routed" "internalRouted" {
  name         = "Routed 192.168.1.0/24"
# Указывается имя edge шлюза
  edge_gateway = var.vcd_org_edge_name
# Шлюз сети организации
  gateway = "192.168.1.1"
# 
  dhcp_pool {
    start_address = "192.168.1.2"
    end_address   = "192.168.1.100"
  }

  static_ip_pool {
    start_address = "192.168.1.101"
    end_address   = "192.168.1.254"
  }
}

# Создание vApp

resource "vcd_vapp" "vms" {
  name = "applica"
  power_on = "true"

  depends_on = [vcd_network_routed.internalRouted]
}

# Создание виртуальной машины vm1 в vApp

resource "vcd_vapp_vm" "vm1" {
  vapp_name     = vcd_vapp.vms.name
  name          = "applica_vm1"
  catalog_name  = var.vcd_org_catalog
  template_name = var.template_vm
  memory        = 2048
  cpus          = 2
  cpu_cores     = 1

  depends_on = [vcd_network_routed.internalRouted, vcd_vapp.regru]

  network {
    type               = "org"
    name               = vcd_network_routed.internalRouted.name
    ip                 = "192.168.1.101"
    ip_allocation_mode = "MANUAL"
  }

  guest_properties = {
    "guest.hostname" = "vm1.host.ru"
  }

  initscript = <<EOF
#!/bin/bash
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
echo "ssh-rsa public_key user@host" >> ~/.ssh/authorized_keys
hostnamectl set-hostname vm2.host.ru
EOF

}

# Создание виртуальной машины vm2 в vApp

resource "vcd_vapp_vm" "vm2" {
  vapp_name     = vcd_vapp.vms.name
  name          = "applica_vm2"
  catalog_name  = var.vcd_org_catalog
  template_name = var.template_vm
  memory        = 2048
  cpus          = 2
  cpu_cores     = 1

  depends_on = [vcd_network_routed.internalRouted, vcd_vapp.regru]

  network {
    type               = "org"
    name               = vcd_network_routed.internalRouted.name
    ip                 = "192.168.1.102"
    ip_allocation_mode = "MANUAL"
  }

  guest_properties = {
    "guest.hostname" = "vm2.host.ru"
  }

  initscript = <<EOF
#!/bin/bash
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
echo "ssh-rsa public_key user@host" >> ~/.ssh/authorized_keys
hostnamectl set-hostname vm2.host.ru
EOF

}

# Разрешаем Интернет в сеть 192.168.1.0/24

resource "vcd_firewall_rules" "Internet" {
  edge_gateway   = var.vcd_org_edge_name
  default_action = "allow"

  rule {
    description      = "Internet to 192.168.1.0/24"
    policy           = "allow"
    protocol         = "any"
    destination_port = "any"
    destination_ip   = "192.168.1.0/24"
    source_port      = "any"
    source_ip        = "any"
  }

  depends_on = [vcd_network_routed.internalRouted]
}

# SNAT

resource "vcd_snat" "outbound" {
  description  = "SNAT rule"
  edge_gateway = var.vcd_org_edge_name
  network_type = "org"
  external_ip  = "194.67.117.132"
  internal_ip  = "192.168.1.0/24"

  depends_on = [vcd_network_routed.internalRouted]
}

# DNAT for vm1

resource "vcd_dnat" "to_vm1" {
  edge_gateway    = var.vcd_org_edge_name
  external_ip     = "194.67.117.132"
  port            = 22101
  internal_ip     = "192.168.1.101"
  translated_port = 22

  depends_on = [vcd_network_routed.internalRouted]
}

# DNAT for reg2 machine

resource "vcd_dnat" "to_vm2" {
  edge_gateway    = var.vcd_org_edge_name
  external_ip     = "194.67.117.132"
  port            = 22102
  internal_ip     = "192.168.1.102"
  translated_port = 22

  depends_on = [vcd_network_routed.internalRouted]
}
