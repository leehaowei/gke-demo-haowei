resource "google_service_account" "github_actions" {
  account_id   = "github-actions-deployer"
  display_name = "GitHub Actions Deploy Service Account"
}

# --- GKE Permissions ---
resource "google_project_iam_member" "github_actions_k8s_developer" {
  project = local.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_actions_k8s_viewer" {
  project = local.project_id
  role    = "roles/container.clusterViewer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# --- Cloud Build Private Worker Pool Access ---
resource "google_project_iam_member" "github_actions_cloudbuild_worker_pool_user" {
  project = local.project_id
  role    = "roles/cloudbuild.workerPoolUser"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# --- Artifact Registry Access (Optional) ---
resource "google_project_iam_member" "github_actions_artifact_registry_reader" {
  project = local.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_actions_artifact_registry_writer" {
  project = local.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# --- VPC Access (Optional - if accessing private GKE or Cloud NAT, etc.) ---
resource "google_project_iam_member" "github_actions_network_user" {
  project = local.project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# --- Output for use in GitHub Secrets ---
output "github_actions_sa_email" {
  value       = google_service_account.github_actions.email
  description = "Email of the GitHub Actions deployer service account."
}
