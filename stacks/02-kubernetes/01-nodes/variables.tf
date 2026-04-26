variable "proxmox_api_url" { type = string }
variable "proxmox_api_id" { type = string }
variable "proxmox_api_secret" {
    type = string
    sensitive = true
}
variable "ssh_public_key" { type = string }
variable "vault_token" {
    type = string
    sensitive = true
}

variable "k8s_network" {
  type = object({ gateway = string, vlan = number, dns = string })
  default = {
    gateway = "10.0.50.1"
    vlan    = 50
    dns     = "10.0.50.1"
  }
}

variable "k8s_masters" {
  type = map(object({ node = string, vm_id = number, ip = string, cpu = number, ram = number, disk = number }))
  default = {
    "k8s-master-01" = { node = "node1", vm_id = 5011, ip = "10.0.50.11", cpu = 4, ram = 4096, disk = 20 }
    "k8s-master-02" = { node = "node1", vm_id = 5012, ip = "10.0.50.12", cpu = 4, ram = 4096, disk = 20 }
    "k8s-master-03" = { node = "node2", vm_id = 5013, ip = "10.0.50.13", cpu = 2, ram = 4096, disk = 20 }
  }
}

variable "k8s_workers" {
  type = map(object({ node = string, vm_id = number, ip = string, cpu = number, ram = number, disk = number, gpu = bool }))
  default = {
    "k8s-worker-01" = { node = "node1", vm_id = 5021, ip = "10.0.50.21", cpu = 8, ram = 16384, disk = 20, gpu = true }
    "k8s-worker-02" = { node = "node1", vm_id = 5022, ip = "10.0.50.22", cpu = 8, ram = 16384, disk = 20, gpu = false }
    
    # Node 2
    "k8s-worker-03" = { node = "node2", vm_id = 5023, ip = "10.0.50.23", cpu = 4, ram = 4096, disk = 20, gpu = false }
    "k8s-worker-04" = { node = "node2", vm_id = 5024, ip = "10.0.50.24", cpu = 4, ram = 4096, disk = 20, gpu = false }
    "k8s-worker-05" = { node = "node2", vm_id = 5025, ip = "10.0.50.25", cpu = 4, ram = 4096, disk = 20, gpu = false }
  }
}