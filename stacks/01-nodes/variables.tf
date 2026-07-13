variable "proxmox_api_url" { type = string }
variable "proxmox_api_id" { type = string }
variable "proxmox_api_secret" {
  type      = string
  sensitive = true
}
variable "ssh_public_key" { type = string }

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
    "k8s-master-00" = { node = "node1", vm_id = 5010, ip = "10.0.50.10", cpu = 3, ram = 4096, disk = 100 }
    "k8s-master-01" = { node = "node1", vm_id = 5011, ip = "10.0.50.11", cpu = 3, ram = 4096, disk = 100 }
    "k8s-master-02" = { node = "node1", vm_id = 5012, ip = "10.0.50.12", cpu = 3, ram = 4096, disk = 100 }
  }
}

variable "k8s_workers" {
  type = map(object({ node = string, vm_id = number, ip = string, cpu = number, ram = number, disk = number, gpu = bool }))
  default = {
    "k8s-worker-00" = { node = "node1", vm_id = 5020, ip = "10.0.50.20", cpu = 8, ram = 24576, disk = 100, gpu = true }
    "k8s-worker-01" = { node = "node1", vm_id = 5021, ip = "10.0.50.21", cpu = 8, ram = 24576, disk = 100, gpu = false }

    # Node 2

    "k8s-worker-02" = { node = "node2", vm_id = 5030, ip = "10.0.50.30", cpu = 8, ram = 12288, disk = 200, gpu = false }
    "k8s-worker-03" = { node = "node2", vm_id = 5031, ip = "10.0.50.31", cpu = 8, ram = 12288, disk = 200, gpu = false }
  }
}
