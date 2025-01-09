#cloud-config

package_update: true
package_upgrade: true
package_reboot_if_required: true

# Install essential packages
packages:
  - curl
  - open-vm-tools
  - nfs-common
  - net-tools
  - apt-transport-https
  - ca-certificates
  - software-properties-common
  - lsb-release

write_files:
  # Kubernetes networking configuration
  - path: /etc/sysctl.d/kubernetes.conf
    content: |
      net.bridge.bridge-nf-call-ip6tables = 1
      net.bridge.bridge-nf-call-iptables = 1
      net.ipv4.ip_forward = 1
  # Required kernel modules
  - path: /etc/modules-load.d/containerd.conf
    content: |
      overlay
      br_netfilter
  - path: /etc/containerd/config.toml
    content: |
      version = 2
      [plugins]
      [plugins."io.containerd.grpc.v1.cri"]
      [plugins."io.containerd.grpc.v1.cri".containerd]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
      runtime_type = "io.containerd.runc.v2"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
      SystemdCgroup = true
  # K3s installation script
  - path: /usr/local/bin/k3s-install.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" \
        K3S_KUBECONFIG_MODE="644" \
        K3S_TOKEN="Ulzkam21em00" \
        sh -s - \
        --node-taint CriticalAddonsOnly=true:NoExecute

runcmd:
  - modprobe overlay && modprobe br_netfilter
  - sysctl --system
  - hostnamectl set-hostname ${HOSTNAME}
  - swapoff -a
  - sed -i '/swap/d' /etc/fstab
  - rm -f /swap.img
  - /usr/local/bin/k3s-install.sh
  - echo "Cloud-init completed at $(date)" > /root/cloudinit.log

cloud_config_modules:
  - apt-configure
  - apt-update-upgrade
  - updates-check
  - runcmd
  - write-files
