# Output the public IP addresses of the instances if enabled
output "control_plane_public_ip" {
  value       = var.enable_public_ips ? google_compute_instance.control_plane.network_interface[0].access_config[0].nat_ip : "Public IP disabled"
  description = "The public IP address of the control plane node"
}

output "worker_public_ips" {
  value       = var.enable_public_ips ? [for instance in google_compute_instance.worker : instance.network_interface[0].access_config[0].nat_ip] : ["Public IP disabled"]
  description = "The public IP addresses of the worker nodes"
}

# Output the private IP addresses of the instances
output "control_plane_private_ip" {
  value       = google_compute_instance.control_plane.network_interface[0].network_ip
  description = "The private IP address of the control plane node"
}

output "worker_private_ips" {
  value       = [for instance in google_compute_instance.worker : instance.network_interface[0].network_ip]
  description = "The private IP addresses of the worker nodes"
}

# Output information useful for cluster setup
output "control_plane_name" {
  value       = google_compute_instance.control_plane.name
  description = "The name of the control plane instance"
}

output "worker_names" {
  value       = [for instance in google_compute_instance.worker : instance.name]
  description = "The names of the worker instances"
}

# SSH command to connect to the control plane
output "ssh_to_control_plane" {
  value       = "ssh ${var.ssh_user}@${var.enable_public_ips ? google_compute_instance.control_plane.network_interface[0].access_config[0].nat_ip : google_compute_instance.control_plane.network_interface[0].network_ip}"
  description = "Command to SSH into the control plane"
}

# Output information about auto-shutdown schedule
output "auto_shutdown_time" {
  value       = "Instances are scheduled to shut down daily at 6:00 PM ${var.scheduler_time_zone} time"
  description = "Information about when instances will shut down"
}

output "auto_startup_time" {
  value       = var.enable_auto_startup ? "Instances are scheduled to start up at 8:00 AM ${var.scheduler_time_zone} time on weekdays" : "Auto-startup is disabled"
  description = "Information about when instances will start up (if enabled)"
}

output "kubernetes_join_command_hint" {
  value       = "After initializing the control plane with 'kubeadm init', run 'kubeadm token create --print-join-command' to get the command for joining worker nodes."
  description = "Hint for getting the join command for worker nodes"
}
