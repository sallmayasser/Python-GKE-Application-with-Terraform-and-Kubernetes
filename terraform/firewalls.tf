# resource "google_compute_firewall" "allow-egress-to-google-apis" {
#   name    = "${var.prefix}-allow-egress-to-google-apis"
#   network = google_compute_network.my-vpc.name
#   project = var.project_id

#   allow {
#     protocol = "all"
#   }

#   source_ranges      = [google_compute_subnetwork.restricted.ip_cidr_range]
#   destination_ranges = ["199.36.153.8/30"]
#   direction          = "EGRESS"
#   priority           = 850
# }

# #  1.  Deny All Egress from restricted Subnet 
# resource "google_compute_firewall" "deny_all_egress_from_restricted" {
#   name    = "${var.prefix}-deny-all-egress-restricted"
#   network = google_compute_network.my-vpc.name
#   project = var.project_id
#   deny {
#     protocol = "all"
#   }

#   source_ranges      = [google_compute_subnetwork.restricted.ip_cidr_range]
#   destination_ranges = ["0.0.0.0/0"]
#   direction          = "EGRESS"
#   priority           = 1000
# }

# # 2. Allow restricted Subnet to Access management Subnet  
# resource "google_compute_firewall" "allow-egress-to-management" {
#   name    = "allow-egress-to-management"
#   network = google_compute_network.my-vpc.name
#   project = var.project_id

#   allow {
#     protocol = "all"
#   }

#   source_ranges      = [google_compute_subnetwork.restricted.ip_cidr_range]
#   destination_ranges = [google_compute_subnetwork.management.ip_cidr_range]
#   direction          = "EGRESS"
#   priority           = 900
# }

# 3. Allow SSH via IAP (for secure remote access)
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

# 4. Allow GKE master access Traffic in management Subnet
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


