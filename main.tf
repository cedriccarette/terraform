# Terraform Block
terraform {
  required_version = "0.13.5"
  required_providers {
    vcd = {
      source = "vmware/vcd"
      version = "3.0.0"
    }
  }
}

# Provider Block
provider "vcd" {
  user = var.UserName
  password = var.UserPassword
  auth_type = "integrated"
  org = var.OrgName
  vdc = var.OrgVdcName 
  url = "https://my.bizzcloud.be/api"
}

# Resource Blocks
resource "vcd_vapp" "Vapp" {
  name = var.VappName
}

resource "vcd_vapp_network" "vAppNet" {
  name  = var.VappNetworkName
  vapp_name = vcd_vapp.Vapp.name
  gateway = "192.168.13.1"
  netmask = "255.255.255.0"
  dns1 = "195.238.2.21"
  dns2 = "8.8.8.8"
  static_ip_pool {
    start_address = "192.168.13.100"
    end_address = "192.168.13.199"
  }
}

resource "vcd_vapp_org_network" "vappOrgNet" {
  vapp_name = vcd_vapp.Vapp.name
  org_network_name  = var.OrgVcdNetworkName
}

resource "vcd_vapp_vm" "vm1" {
  name = var.Vm1Name
  computer_name = var.Vm1Name
  vapp_name = vcd_vapp.Vapp.name
  power_on = false
  cpu_hot_add_enabled = true
  memory_hot_add_enabled = true
  catalog_name = "Public_Catalog"
  template_name = var.TemplateWindows
#  storage_profile = var.Tier0
  memory = 4096
  cpus = 1
  cpu_cores = 1
  network {
    name = vcd_vapp_network.vAppNet.name
    type = "vapp"
    ip_allocation_mode = "MANUAL"
    ip = "192.168.13.100"
    adapter_type = "VMXNET3"
    is_primary = true
  }
}

resource "vcd_vapp_vm" "vm2" {
  name = var.Vm2Name
  computer_name = var.Vm2Name
  vapp_name = vcd_vapp.Vapp.name
  power_on = false
  cpu_hot_add_enabled = true
  memory_hot_add_enabled = true
  catalog_name  = "Public_Catalog"
  template_name = var.TemplateWindows
#  storage_profile = var.Tier0
  memory = 6144
  cpus = 2
  cpu_cores = 1
  network {
    name = vcd_vapp_network.vAppNet.name
    type = "vapp"
    ip_allocation_mode = "MANUAL"
    ip = "192.168.13.101"
    adapter_type = "VMXNET3"
    is_primary = true
  }
}

resource "vcd_vm_internal_disk" "vm2_disk1" {
  vapp_name = vcd_vapp.Vapp.name
  vm_name         = vcd_vapp_vm.vm2.name
  bus_type        = "paravirtual"
  size_in_mb      = "5120"
  bus_number      = 1
  unit_number     = 1
}

resource "vcd_vm_internal_disk" "vm2_disk2" {
  vapp_name = vcd_vapp.Vapp.name
  vm_name         = vcd_vapp_vm.vm2.name
  bus_type        = "paravirtual"
  size_in_mb      = "5120"
  bus_number      = 1
  unit_number     = 2
  depends_on      = [ vcd_vm_internal_disk.vm2_disk1 ]
}

resource "vcd_vapp_vm" "vm3" {
  name = var.Vm3Name
  computer_name = var.Vm3Name
  vapp_name = vcd_vapp.Vapp.name
  power_on = false
  cpu_hot_add_enabled = true
  memory_hot_add_enabled = true
  catalog_name = "Public_Catalog"
  template_name = var.TemplateFireboxV
  memory = 1024
  cpus = 1
  cpu_cores = 1
  network {
    name = var.OrgVcdNetworkName
    type = "org"
    ip_allocation_mode = "POOL"
    adapter_type = "VMXNET3"
    is_primary = true
  }
  network {
    name = vcd_vapp_network.vAppNet.name
    type = "vapp"
    ip_allocation_mode = "MANUAL"
    ip = "192.168.13.254"
    adapter_type = "VMXNET3"
    is_primary = false
  }
}
