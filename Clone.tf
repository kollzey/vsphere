#Basic Configuration without variables

#Define authentication configuration
provider "vsphere" {
  # If you use a domain set your login like this "Domain\\User"
  user           = "administrator@vsphere.loacl"
  password       = "P@ssw0rd"
  vsphere_server = "vcsa.homelab.com"

  #If you have a self-signed cert
  allow_unverified_ssl = true
}

#### RETRIEVE DATA INFORMATION ON VCENTER ####

data "vsphere_datacenter" "dc" {
  name = "Datacenter"
}

data "vsphere_resource_pool" "pool" {
  name          = "New Resource Pool"
  datacenter_id = data.vsphere_datacenter.dc.id
}

#Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

#Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

#Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = "testvm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

#### VM CREATION #####

# Set vm parameters

resource "vsphere_virtual_machine" "demo" {
  name               = "terraform"
  num_cpus           = 2
  memory             = 4096
  datastore_id       = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id           = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  # Use a predefined vmware template as main disk
  disk {
    label = "terraform.vmdk"
    size  = "20"
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    }
}