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

#RESOURCES:
resource "random_password" "password" {
  length = 20
  count = var.vm_count
  override_special = "!#$%*()-_=+[]{}:?"
}

resource "google_compute_instance" "vm_instance" {
  name         = "vm${count.index}"
  machine_type = "e2-micro"
  count = var.vm_count
  metadata_startup_script = <<SCRIPT
    apt-get update && apt-get -y install whois && useradd -m -G google-sudoers -p $(mkpasswd -m sha-512 "${random_password.password[count.index].result}") -s /bin/bash admin
    SCRIPT

  #metadata = {
  #  ssh-keys = "ffhmichels:${file("${var.public_key_file}")}"
  #}

  boot_disk {
    initialize_params {
      image = var.vm_image
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

data "external" "ping_test" {
  count = var.vm_count
  working_dir = abspath("")
  program = ["bash", "ping_test.sh", "${var.project_id}", "${var.zone}", "vm${count.index}", "${var.private_key_file}", "vm${(count.index + 1)%"${var.vm_count}"}"]
  depends_on = [
    google_compute_instance.vm_instance
  ]
}

output "ip" {
  value = google_compute_instance.vm_instance[*].network_interface.0.network_ip
}

output "ping" {
  value = data.external.ping_test[*].result
}
