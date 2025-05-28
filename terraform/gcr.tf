resource "google_artifact_registry_repository" "salma-repo" {
  location      = var.region
  repository_id = "${var.prefix}-repository"
  format        = "DOCKER"
}
