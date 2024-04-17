#use google cloud
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_id
  zone = var.zone
}

# generate random passwords to use for admin account
resource "random_password" "password" {
  length = 20
  count = var.vm_count
  override_special = "!#$%*()-_=+[]{}:?"
}

# setup instances with startup script
resource "google_compute_instance" "vm_instance" {
  name         = "vm${count.index}"
  machine_type = var.vm_flavor[count.index]
  count = var.vm_count
  metadata_startup_script = <<SCRIPT
    apt-get update \
    && apt-get -y install whois \
    && useradd -m -G google-sudoers -p $(mkpasswd -m sha-512 "${random_password.password[count.index].result}") -s /bin/bash admin
    SCRIPT

  boot_disk {
    initialize_params {
      image = var.vm_image[count.index]
    }
  }

  network_interface {
    network    = "vpc-network"
    subnetwork = google_compute_subnetwork.internal-subnet.name
  }

  depends_on = [ 
    google_compute_firewall.icmp-rule,
    google_compute_firewall.ssh-rule,
  ]
}

# after google cloud sends back OK for instances wait 20sec for them to boot
resource "time_sleep" "wait_20_seconds" {
  depends_on = [google_compute_instance.vm_instance]
  destroy_duration = "0s"
  create_duration = "20s"
}

# execute ping test on every vm through google ssh proxy, refer to ping_test.sh script
data "external" "ping_test" {
  count = var.vm_count
  working_dir = abspath("")
  program = ["bash", "ping_test.sh", "${var.project_id}", "${var.zone}", "vm${count.index}", "${var.private_key_file}", "vm${(count.index + 1)%"${var.vm_count}"}"]

  depends_on = [
    time_sleep.wait_20_seconds
  ]
}

# output vm interal ips
output "ip" {
  value = google_compute_instance.vm_instance[*].network_interface.0.network_ip
}

# output ping results
output "ping" {
  value = data.external.ping_test[*].result
}
