locals {
  all_k8s_vms = merge(var.k8s_masters, var.k8s_workers)
  k8s_nodes   = distinct([for v in local.all_k8s_vms : v.node])

  k8s_config = <<EOT
#cloud-config
hostname: $${hostname}
users:
  - name: root
    ssh_authorized_keys:
      - ${trimspace(var.ssh_public_key)}

runcmd:
  - exec > /var/log/infra-setup.log 2>&1
  - echo "--- Starting K8S Infrastructure Setup (v1.36) ---"
  
  # 1. TEMPS, DNS ET HOSTNAME
  - timedatectl set-ntp true
  - echo "nameserver 1.1.1.1" > /etc/resolv.conf
  - echo "127.0.0.1 localhost $${hostname}" > /etc/hosts
  - sleep 5

  # 2. PRÉREQUIS SYSTÈME (Kernel, Swap & Privileged Ports)
  - swapoff -a
  - sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  - modprobe overlay && modprobe br_netfilter
  - |
    cat <<EOF > /etc/modules-load.d/k8s.conf
    overlay
    br_netfilter
    EOF
  - |
    cat <<EOF > /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-iptables  = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    net.ipv4.ip_forward                 = 1
    net.ipv4.ip_unprivileged_port_start = 0
    EOF
  - sysctl --system

  # 3. RÉPARATION CA-CERTIFICATES
  - export DEBIAN_FRONTEND=noninteractive
  - apt-get update -y || true
  - apt-get install -y ca-certificates openssl --reinstall
  - update-ca-certificates

  # 4. INSTALLATION NFS-COMMON, TOOLS & CONTAINERD
  - apt-get install -y nfs-common curl gpg gnupg2 jq containerd

  # 5. CONFIGURATION DES DÉPÔTS (Bypass SSL via -k)
  - mkdir -p /etc/apt/keyrings
  - curl -fsSLk https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  - echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
  - curl -fsSLk https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor --yes -o /usr/share/keyrings/helm.gpg
  - echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" > /etc/apt/sources.list.d/helm-stable-debian.list

  # 6. INSTALLATION KUBERNETES, HELM & CNI
  - apt-get update -o "Acquire::https::Verify-Peer=false"
  - apt-get install -y -o "Acquire::https::Verify-Peer=false" kubelet kubeadm kubectl helm kubernetes-cni
  - apt-mark hold kubelet kubeadm kubectl

  # 7. CONFIGURATION CONTAINERD (Standard K8S + SystemdCgroup)
  - mkdir -p /etc/containerd
  - containerd config default > /etc/containerd/config.toml
  # On force containerd à utiliser /opt/cni/bin (le standard K8S) au lieu du chemin Debian
  - sed -i 's|bin_dir = "/usr/lib/cni"|bin_dir = "/opt/cni/bin"|' /etc/containerd/config.toml
  - sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
  - systemctl restart containerd
  - systemctl enable --now containerd

  # 8. VÉRIFICATION ET FINALISATION
  - while [ ! -S /var/run/containerd/containerd.sock ]; do echo "Waiting for containerd socket..."; sleep 2; done
  - systemctl daemon-reload
  - systemctl enable --now kubelet
  - echo "--- Setup Complete ---"
EOT
}