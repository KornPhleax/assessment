
# Create a VPC
resource "google_compute_network" "vpc-network" {
  name                    = "vpc-network"
  auto_create_subnetworks = "false"

}

# Create a Subnet
resource "google_compute_subnetwork" "internal-subnet" {
  name          = "internal-subnet-assessment"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc-network.name
  region        = var.region
}

resource "google_compute_firewall" "ssh-rule" {
  project = var.project_id
  name    = "allow-ssh-from-google"
  network = "vpc-network"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]

  depends_on = [
    google_compute_network.vpc-network
  ]
}

resource "google_compute_firewall" "icmp-rule" {
  project = var.project_id
  name    = "allow-ping-from-internal"
  network = "vpc-network"

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/24"]

  depends_on = [
    google_compute_network.vpc-network
  ]
}

resource "google_compute_router" "router" {
  project = var.project_id
  name    = "nat-router"
  network = "vpc-network"
  region  = var.region

  depends_on = [
    google_compute_network.vpc-network
  ]
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  depends_on = [
    google_compute_network.vpc-network
  ]
}
