# Create a custom VPC network
resource "google_compute_network" "k8s_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Create a subnet within the VPC
resource "google_compute_subnetwork" "k8s_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.k8s_network.id
  region        = var.region
}

# Create firewall rules

# Allow internal communication across all protocols
resource "google_compute_firewall" "k8s_internal" {
  name    = "${var.network_name}-internal"
  network = google_compute_network.k8s_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = [var.subnet_cidr]
}

# Allow SSH from external
resource "google_compute_firewall" "k8s_ssh" {
  name    = "${var.network_name}-ssh"
  network = google_compute_network.k8s_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # In production, restrict to your IP
}

# Allow Kubernetes API server
resource "google_compute_firewall" "k8s_api" {
  name    = "${var.network_name}-api"
  network = google_compute_network.k8s_network.name

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = ["0.0.0.0/0"] # In production, restrict to your IP
}

# Allow NodePort services
resource "google_compute_firewall" "k8s_nodeport" {
  name    = "${var.network_name}-nodeport"
  network = google_compute_network.k8s_network.name

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create a static IP for the control plane
resource "google_compute_address" "k8s_control_plane_ip" {
  name   = "${var.control_plane_name}-ip"
  region = var.region
}

# Create an internet gateway
resource "google_compute_router" "k8s_router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.k8s_network.id
}

# Configure NAT for private instances to access the internet
resource "google_compute_router_nat" "k8s_nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.k8s_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
