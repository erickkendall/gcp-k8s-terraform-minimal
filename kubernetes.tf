# Create control plane instance
resource "google_compute_instance" "control_plane" {
  name         = var.control_plane_name
  machine_type = var.machine_type
  zone         = var.zone

  # Add resource policies for auto-shutdown and auto-startup (directly attached to VM)
  resource_policies = var.enable_auto_startup ? [
    google_compute_resource_policy.daily_shutdown.id,
    google_compute_resource_policy.daily_startup[0].id
    ] : [
    google_compute_resource_policy.daily_shutdown.id
  ]

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size_gb
      type  = var.disk_type
    }
  }

  network_interface {
    network    = google_compute_network.k8s_network.name
    subnetwork = google_compute_subnetwork.k8s_subnet.name

    dynamic "access_config" {
      for_each = var.enable_public_ips ? [1] : []
      content {
        nat_ip = google_compute_address.k8s_control_plane_ip.address
      }
    }
  }

  tags = var.control_plane_tags

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = local.startup_script

  labels = {
    "kubernetes-role" = "control-plane"
    "auto-shutdown"   = "enabled"
  }

  # Schedule-specific settings
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  # Allow instance to be stopped by the instance scheduler
  allow_stopping_for_update = true

  depends_on = [
    google_compute_subnetwork.k8s_subnet,
    google_project_iam_member.instance_scheduler_role
  ]
}

# Create worker node instances
resource "google_compute_instance" "worker" {
  count        = var.worker_count
  name         = "${var.worker_name_prefix}-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  # Add resource policies for auto-shutdown and auto-startup (directly attached to VM)
  resource_policies = var.enable_auto_startup ? [
    google_compute_resource_policy.daily_shutdown.id,
    google_compute_resource_policy.daily_startup[0].id
    ] : [
    google_compute_resource_policy.daily_shutdown.id
  ]

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size_gb
      type  = var.disk_type
    }
  }

  network_interface {
    network    = google_compute_network.k8s_network.name
    subnetwork = google_compute_subnetwork.k8s_subnet.name

    dynamic "access_config" {
      for_each = var.enable_public_ips ? [1] : []
      content {
        // Ephemeral public IP
      }
    }
  }

  tags = var.worker_tags

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = local.startup_script

  labels = {
    "kubernetes-role" = "worker"
    "auto-shutdown"   = "enabled"
  }

  # Schedule-specific settings
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  # Allow instance to be stopped by the instance scheduler
  allow_stopping_for_update = true

  depends_on = [
    google_compute_subnetwork.k8s_subnet,
    google_project_iam_member.instance_scheduler_role
  ]
}
