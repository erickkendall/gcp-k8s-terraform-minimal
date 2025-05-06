#!/bin/bash
# This script should be run on the worker node to join the Kubernetes cluster
# Replace the following with the actual join command from the control plane

# First, ensure the node is ready
if [ ! -f /tmp/k8s_prereqs_installed ]; then
  echo "Kubernetes prerequisites not installed. Please wait for the startup script to complete."
  exit 1
fi

# Replace with actual token and discovery hash from control plane
# This is a placeholder and will need to be updated with the actual join command
CONTROL_PLANE_IP="REPLACE_WITH_CONTROL_PLANE_IP"
TOKEN="REPLACE_WITH_TOKEN"
DISCOVERY_HASH="REPLACE_WITH_HASH"

# Join the cluster
echo "Joining the Kubernetes cluster..."
sudo kubeadm join ${CONTROL_PLANE_IP}:6443 --token ${TOKEN} --discovery-token-ca-cert-hash ${DISCOVERY_HASH}

echo "Worker node joined the cluster successfully!"
