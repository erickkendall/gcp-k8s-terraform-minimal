#!/bin/bash
# This script initializes the Kubernetes control plane

# Set variables
POD_NETWORK_CIDR="10.244.0.0/16"
CONTROL_PLANE_IP=$(hostname -I | awk '{print $1}')

# Initialize the control plane
echo "Initializing Kubernetes control plane..."
sudo kubeadm init --pod-network-cidr=$POD_NETWORK_CIDR --apiserver-advertise-address=$CONTROL_PLANE_IP | tee /tmp/kubeadm-init.log

# Set up kubeconfig for the current user
echo "Setting up kubeconfig..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel network plugin
echo "Installing Flannel network plugin..."
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Get the join command for worker nodes
JOIN_COMMAND=$(grep -A 1 "kubeadm join" /tmp/kubeadm-init.log | tr -d '\n' | sed 's/\\//g')
echo "Worker join command: $JOIN_COMMAND"
echo $JOIN_COMMAND > /tmp/worker-join-command.sh
chmod +x /tmp/worker-join-command.sh

# Verify cluster status
echo "Verifying cluster status..."
kubectl get nodes
kubectl get pods --all-namespaces

echo "Control plane setup complete!"
echo "Use the following command to join worker nodes:"
echo "$JOIN_COMMAND"
