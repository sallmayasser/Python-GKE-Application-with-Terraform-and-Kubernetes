# ////////////////////////////////// VPC and Subnet ////////////////////////////
resource "google_compute_network" "my-vpc" {
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "management" {
  name                     = "${var.prefix}-management-subnet"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = var.region
  network                  = google_compute_network.my-vpc.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "restricted" {
  name                     = "${var.prefix}-restricted-subnet"
  ip_cidr_range            = "10.0.2.0/24"
  region                   = var.region
  network                  = google_compute_network.my-vpc.id
  private_ip_google_access = true
}
# ////////////////////////////////// Nat ///////////////////////////
resource "google_compute_router" "router" {
  name    = "${var.prefix}-router"
  region  = var.region
  network = google_compute_network.my-vpc.id
}

resource "google_compute_router_nat" "nat_manual" {
  name                   = "${var.prefix}-router-nat"
  router                 = google_compute_router.router.name
  region                 = var.region
  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.management.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
