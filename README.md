# GCP Kubernetes Terraform Minimal Cluster with Auto-Shutdown

This repository contains Terraform configurations for deploying a minimal two-node Kubernetes cluster on Google Cloud Platform with an automatic shutdown feature. The goal of this project is to provide a cost-effective way to learn and practice Kubernetes for the CKA exam.

## Features

- Minimalist two-node Kubernetes cluster (one control plane, one worker)
- Complete infrastructure as code using Terraform
- Automatic shutdown at 6 PM to save costs
- Optional automatic startup at 8 AM on weekdays
- All components organized in separate files for better understanding
- Private or public IP configurations supported

## Prerequisites

- [Google Cloud Platform](https://cloud.google.com/) account
- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or newer)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- SSH key pair for node access

## Project Structure

```
gcp-k8s-terraform-minimal/
├── main.tf                  # Provider configuration
├── variables.tf             # Variable definitions
├── terraform.tfvars         # Variable values
├── outputs.tf               # Output definitions
├── network.tf               # Network resources
├── kubernetes.tf            # Kubernetes node configuration
├── scheduler.tf             # Auto-shutdown configuration
├── scripts/                 # Utility scripts
│   ├── setup-kubernetes.sh  # Script to set up the control plane
│   ├── join-worker.sh       # Script to join worker nodes
└── README.md                # This readme file
```

## Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/gcp-k8s-terraform-minimal.git
   cd gcp-k8s-terraform-minimal
   ```

2. Edit `terraform.tfvars` to set your GCP project ID and other preferences.

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Apply the Terraform configuration:
   ```bash
   terraform plan
   terraform apply
   ```

5. After the infrastructure is created, SSH into the control plane node:
   ```bash
   ssh ubuntu@$(terraform output -raw control_plane_public_ip)
   ```

6. Run the setup script to initialize Kubernetes:
   ```bash
   curl -O https://raw.githubusercontent.com/yourusername/gcp-k8s-terraform-minimal/main/scripts/setup-kubernetes.sh
   chmod +x setup-kubernetes.sh
   ./setup-kubernetes.sh
   ```

7. Copy the join command and SSH into the worker node:
   ```bash
   ssh ubuntu@$(terraform output -raw worker_public_ips | jq -r '.[0]')
   ```

8. Run the join command on the worker node.

9. Return to the control plane node and verify the cluster:
   ```bash
   kubectl get nodes
   ```

## Auto-Shutdown Feature

This project includes an automatic shutdown feature to help save costs when studying for the CKA exam:

- Instances are automatically shut down at 6 PM every day
- If enabled, instances are automatically started at 8 AM on weekdays
- You can modify these times by editing the `scheduler.tf` file
- To change the time zone, update the `scheduler_time_zone` variable in `terraform.tfvars`
- To disable auto-startup, set `enable_auto_startup = false
