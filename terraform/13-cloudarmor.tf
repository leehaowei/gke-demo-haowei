resource "google_compute_security_policy" "nginx" {
  name        = "nginx-cloud-armor-policy"
  description = "Protect nginx ingress"
}

resource "google_storage_bucket" "infra_outputs" {
  name          = "${local.project_id}-infra-output"
  location      = "US"
  force_destroy = true
}

output "cloudarmor_policy_name" {
  value = google_compute_security_policy.nginx.name
}

output "infra_outputs_bucket" {
  value = google_storage_bucket.infra_outputs.name
}