# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Use local variables for common values
locals {
  startup_script = <<-SCRIPT
    #!/bin/bash
    # Update and install basic utilities
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Install Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce

    # Install kubeadm, kubelet and kubectl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    
    # Install specific version if provided, otherwise latest
    if [ -n "${var.kubernetes_version}" ]; then
      apt-get install -y kubelet=${var.kubernetes_version}-00 kubeadm=${var.kubernetes_version}-00 kubectl=${var.kubernetes_version}-00
    else
      apt-get install -y kubelet kubeadm kubectl
    fi
    
    apt-mark hold kubelet kubeadm kubectl
    
    # Disable swap
    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    
    # Set up sysctl params
    cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
    net.bridge.bridge-nf-call-iptables  = 1
    net.ipv4.ip_forward                 = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    EOF
    sysctl --system
    
    # Enable iptables bridge call
    modprobe br_netfilter
    
    # Create a file to indicate successful installation
    touch /tmp/k8s_prereqs_installed
  SCRIPT
}
