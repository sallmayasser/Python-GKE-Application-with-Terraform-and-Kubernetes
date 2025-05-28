# Service account for GKE nodes
resource "google_service_account" "gke_sa" {
  account_id   = "service-account-id"
  display_name = "GKE Node Service Account"
}

# Assign IAM roles to the GKE service account BEFORE cluster/node pool creation
resource "google_project_iam_member" "gke_node_sa_permissions" {
  for_each = toset([
    "roles/container.nodeServiceAccount",
    "roles/compute.networkUser",
    "roles/storage.objectViewer",
    "roles/artifactregistry.reader",
    "roles/iam.serviceAccountUser",
    "roles/compute.instanceAdmin.v1"
  ])

  role    = each.key
  project = var.project_id
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# GKE Cluster definition
resource "google_container_cluster" "primary" {
  name                     = "${var.prefix}-gke-cluster"
  location                 = var.zone
  network                  = google_compute_network.my-vpc.name
  subnetwork               = google_compute_subnetwork.restricted.name
  remove_default_node_pool = true
  deletion_protection      = false
  initial_node_count       = 1

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = google_compute_subnetwork.management.ip_cidr_range
      display_name = "management subnet"
    }
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"

    master_global_access_config {
      enabled = false
    }
  }

  ip_allocation_policy {}
}

# Node Pool with depends_on to ensure IAM roles are ready
resource "google_container_node_pool" "primary_nodes" {
  depends_on = [google_project_iam_member.gke_node_sa_permissions]

  name       = "${var.prefix}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    machine_type    = "e2-medium"
    disk_type       = "pd-standard"
    disk_size_gb    = 50
    service_account = google_service_account.gke_sa.email

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    tags = ["gke-nodes"]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
