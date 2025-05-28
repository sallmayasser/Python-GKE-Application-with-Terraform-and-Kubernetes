# 1. Allow SSH via IAP (for secure remote access)
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.prefix}-allow-iap-ssh"
  network = google_compute_network.my-vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["management"]
  direction     = "INGRESS"
  priority      = 1000
}

# 2. Allow GKE master access Traffic in management Subnet
resource "google_compute_firewall" "gke_master_access" {
  name    = "${var.prefix}-allow-gke-master-access"
  network = google_compute_network.my-vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["443", "80"]
  }
  target_tags = ["gke-nodes"]

  source_ranges = [google_compute_subnetwork.management.ip_cidr_range]
  direction     = "INGRESS"
  priority      = 700
}


