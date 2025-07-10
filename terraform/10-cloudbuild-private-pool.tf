# --- Cloud Build Private Pool Resource ---

resource "google_cloudbuild_worker_pool" "gke_deploy_private_pool" {
  project  = local.project_id
  name     = var.private_pool_name # This variable should be defined in variables.tf
  location = local.region

  worker_config {
    machine_type = "e2-medium"
    disk_size_gb = 100
  }

  network_config {
    peered_network = "projects/${local.project_id}/global/networks/${google_compute_network.vpc.name}" # Reference your VPC from 3-vpc.tf
  }

  depends_on = [google_service_networking_connection.cloud_build_peering]
}

# --- Service Networking Connection for VPC Peering ---
# This sets up the necessary VPC Peering between your VPC and Cloud Build's service producer VPC.
# This assumes your VPC is already managed by Terraform and accessible via `google_compute_network.vpc`.
# If not, you might need to use a `data` block to reference it:
# data "google_compute_network" "existing_vpc" { name = var.vpc_network_name }
# and then use `data.google_compute_network.existing_vpc.id` below.

resource "google_compute_global_address" "cloud_build_private_ip_alloc" {
  project       = local.project_id
  name          = "${var.private_pool_name}-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20                            # A /20 range provides 4096 addresses for the peering.
  network       = google_compute_network.vpc.id # Reference your VPC from 3-vpc.tf
}

resource "google_service_networking_connection" "cloud_build_peering" {
  network                 = google_compute_network.vpc.id # Reference your VPC from 3-vpc.tf
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.cloud_build_private_ip_alloc.name]
}

# --- Output the Private Pool name (useful for reference) ---
output "cloud_build_private_pool_name" {
  value       = google_cloudbuild_worker_pool.gke_deploy_private_pool.name
  description = "Name of the Cloud Build Private Pool."
}