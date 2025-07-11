resource "google_cloudbuildv2_repository" "repo" {
  project     = local.project_id
  location    = local.region
  name        = "gke-demo-haowei"
  parent_connection = "projects/${local.project_id}/locations/${local.region}/connections/github-connection"
  remote_uri = "https://github.com/leehaowei/gke-demo-haowei.git"
}

# Create a dedicated service account for Cloud Build
resource "google_service_account" "cloudbuild_sa" {
  account_id   = "cloudbuild-trigger-sa"
  display_name = "Service Account for Cloud Build Trigger"
  project      = local.project_id
}

# Grant necessary permissions to the service account
resource "google_project_iam_member" "cloudbuild_editor" {
  project = local.project_id
  role    = "roles/cloudbuild.builds.editor" # Allows triggering and managing builds
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

# (Optional, but often needed if builds interact with Artifact Registry)
resource "google_project_iam_member" "artifact_registry_writer" {
  project = local.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

resource "google_cloudbuild_trigger" "github_push_trigger" {
  name     = "gke-nginx-demo-trigger"
  project  = local.project_id
  location = local.region
  
  # Specify the service account
  service_account = google_service_account.cloudbuild_sa.id 

  repository_event_config {
    repository = google_cloudbuildv2_repository.repo.id

    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"

  substitutions = {
    _AR_REPO_NAME = "gke-nginx-demo"
    _IMAGE_NAME   = "gke-nginx-demo"
    _CLUSTER_NAME = "demo"
    _CLUSTER_ZONE = "us-central1-a"
    _REGION       = "us-central1"
  }

  included_files = ["**"]
  ignored_files  = ["README.md"]
}