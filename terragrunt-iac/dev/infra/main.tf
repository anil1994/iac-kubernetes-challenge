resource "google_compute_firewall" "k3s-firewall" {
        name = var.firewall_name
        network = var.network_name
        allow {
                protocol = "tcp"
                ports = ["6443"]
        }
        target_tags = ["k3s"]
}
