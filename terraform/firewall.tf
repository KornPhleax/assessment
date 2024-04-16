resource "google_compute_firewall" "icmp-rule" {
  project = var.project_id
  name    = "allow-ping"
  network = "default"

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]

}