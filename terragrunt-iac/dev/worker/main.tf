resource "google_compute_instance" "k3s_worker_instance" {
  count        = var.machine_count
  name         = "k3s-worker-${count.index}"
  machine_type = var.machine_type
  tags         = ["k3s"]
  zone         = var.zone_name

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
            k3sup join \
            --ip ${self.network_interface[0].access_config[0].nat_ip} \
            --server-ip ${var.master-public-ip} \
            --ssh-key ~/.ssh/google_compute_engine \
            --user $(whoami)
        EOT
  }
}
