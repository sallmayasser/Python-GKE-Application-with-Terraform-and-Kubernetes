# //////////////////// Service account /////////////////
resource "google_service_account" "vm-sa" {
  account_id   = "${var.prefix}-vm-sa"
  display_name = "${var.prefix} service account for Instance"
}

# //////////////////// Service account roles  /////////////////

resource "google_project_iam_member" "vm_sa_roles" {
  for_each = toset([
    "roles/container.clusterAdmin",
    "roles/artifactregistry.admin"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.vm-sa.email}"
}
# //////////////////// Vm instance   /////////////////

resource "google_compute_instance" "management-instance" {
  name         = "${var.prefix}-instance"
  machine_type = "e2-medium"
  zone         = var.zone

  tags = ["management"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.management.id
  }
  service_account {
    email  = google_service_account.vm-sa.email
    scopes = ["cloud-platform"]
  }

}
