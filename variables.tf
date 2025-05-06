# Google Cloud Platform project settings
variable "project_id" {
  description = "The GCP project ID"
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "The project_id variable cannot be empty."
  }
}

variable "region" {
  description = "The GCP region where resources will be created"
  type        = string
  default     = "us-central1"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]+$", var.region))
    error_message = "The region must be a valid GCP region (e.g., us-central1, europe-west1)."
  }
}

variable "zone" {
  description = "The GCP zone where resources will be created"
  type        = string
  default     = "us-central1-a"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]+-[a-z]$", var.zone))
    error_message = "The zone must be a valid GCP zone (e.g., us-central1-a, europe-west1-b)."
  }
}

# Network settings
variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "kubernetes-network"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "kubernetes-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.240.0.0/24"

  validation {
    condition     = can(cidrnetmask(var.subnet_cidr))
    error_message = "The subnet_cidr must be a valid CIDR notation (e.g., 10.240.0.0/24)."
  }
}

variable "pod_network_cidr" {
  description = "CIDR range for the pod network"
  type        = string
  default     = "10.244.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.pod_network_cidr))
    error_message = "The pod_network_cidr must be a valid CIDR notation (e.g., 10.244.0.0/16)."
  }
}

# Instance settings
variable "control_plane_name" {
  description = "Name of the control plane instance"
  type        = string
  default     = "control-plane"
}

variable "worker_name_prefix" {
  description = "Prefix for worker node names"
  type        = string
  default     = "worker"
}

variable "worker_count" {
  description = "Number of worker nodes to create"
  type        = number
  default     = 1

  validation {
    condition     = var.worker_count >= 1
    error_message = "At least one worker node is required for a functioning cluster."
  }
}

variable "machine_type" {
  description = "Machine type for the instances"
  type        = string
  default     = "e2-medium"

  validation {
    condition     = contains(["e2-micro", "e2-small", "e2-medium", "e2-standard-2", "e2-standard-4", "e2-standard-8", "e2-standard-16", "e2-standard-32"], var.machine_type) || can(regex("^[a-z][0-9]?-[a-z]+-[0-9]+$", var.machine_type))
    error_message = "The machine_type must be a valid GCP machine type (e.g., e2-medium, n1-standard-2)."
  }
}

variable "disk_size_gb" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 50

  validation {
    condition     = var.disk_size_gb >= 20
    error_message = "The disk_size_gb must be at least 20 GB to accommodate the OS and Kubernetes components."
  }
}

variable "disk_type" {
  description = "Type of the boot disk"
  type        = string
  default     = "pd-standard"

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd", "pd-extreme"], var.disk_type)
    error_message = "The disk_type must be a valid GCP disk type (pd-standard, pd-balanced, pd-ssd, pd-extreme)."
  }
}

# Kubernetes settings
variable "kubernetes_version" {
  description = "Kubernetes version to install"
  type        = string
  default     = "" # Empty for latest version
}

# SSH settings
variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
  default     = "ubuntu"
}

# Tags
variable "control_plane_tags" {
  description = "Network tags for the control plane instance"
  type        = list(string)
  default     = ["kubernetes", "control-plane"]
}

variable "worker_tags" {
  description = "Network tags for worker instances"
  type        = list(string)
  default     = ["kubernetes", "worker"]
}

# Optional settings
variable "enable_public_ips" {
  description = "Whether to enable public IPs for all nodes"
  type        = bool
  default     = true
}

# Image settings
variable "image" {
  description = "OS image for the instances"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"

  validation {
    condition     = length(var.image) > 0
    error_message = "The image variable cannot be empty."
  }
}

# Auto-shutdown settings
variable "scheduler_time_zone" {
  description = "Time zone for the scheduler"
  type        = string
  default     = "America/New_York" # Change to your time zone

  validation {
    condition     = can(regex("^[A-Za-z]+/[A-Za-z_]+$", var.scheduler_time_zone))
    error_message = "The time_zone must be a valid IANA time zone (e.g., America/New_York, Europe/London)."
  }
}

variable "enable_auto_startup" {
  description = "Whether to enable automatic startup of instances"
  type        = bool
  default     = true
}
