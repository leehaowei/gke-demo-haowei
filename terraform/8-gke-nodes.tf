resource "google_service_account" "gke" {
  account_id = "demo-gke"
}

resource "google_project_iam_member" "gke_logging" {
  project = local.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke.email}"
}

resource "google_project_iam_member" "gke_metrics" {
  project = local.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke.email}"
}

resource "google_project_iam_member" "gke_artifact_registry_reader" {
  project = local.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke.email}"
}

resource "google_container_node_pool" "general" {
  name     = "general"
  location = "us-central1-a"
  cluster  = google_container_cluster.gke.id

  autoscaling {
    total_min_node_count = 1
    total_max_node_count = 5
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = false
    machine_type = "e2-medium"

    labels = {
      role = "general"
    }
    service_account = google_service_account.gke.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# grant permissions to create Google Cloud Load Balancer resources
resource "google_project_iam_member" "gke_load_balancer_admin" {
  project = local.project_id
  role    = "roles/compute.loadBalancerAdmin"
  member  = "serviceAccount:${google_service_account.gke.email}"
}

resource "google_project_iam_member" "gke_network_admin" {
  project = local.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.gke.email}"
}

# Optional but often helpful if the controller creates firewall rules
resource "google_project_iam_member" "gke_security_admin" {
  project = local.project_id
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:${google_service_account.gke.email}"
}

# Add this role, it's often needed for the GKE control plane to manage cluster resources.
# Although less directly for LB, it's a good general GKE SA permission.
resource "google_project_iam_member" "gke_container_admin" {
  project = local.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.gke.email}"
}