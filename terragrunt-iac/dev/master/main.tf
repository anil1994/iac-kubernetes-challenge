resource "google_compute_instance" "k3s-master-instance" {
  name         = var.machine_name
  machine_type = var.machine_type
  tags         =  ["k3s"]
  zone      = var.zone_name

  boot_disk {
    initialize_params {
      image = var.image_name
    }
  }

  network_interface {
    network = var.network_name

    access_config {}
  }

  provisioner "local-exec" {
    command = <<EOT
            k3sup install \
            --ip ${self.network_interface[0].access_config[0].nat_ip} \
            --context k3s \
            --ssh-key ~/.ssh/google_compute_engine \
            --user $(whoami)
        EOT
  }
}

output "public-ip" {
  value = google_compute_instance.k3s-master-instance.network_interface[0].access_config[0].nat_ip
}

