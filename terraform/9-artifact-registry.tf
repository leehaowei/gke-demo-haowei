resource "google_artifact_registry_repository" "gke_repo" {
  provider      = google
  project       = local.project_id
  location      = local.region
  repository_id = "gke-nginx-demo"
  description   = "Docker repository for GKE app"
  format        = "DOCKER"
}