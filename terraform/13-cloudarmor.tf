resource "google_compute_security_policy" "nginx" {
  name        = "nginx-cloud-armor-policy"
  description = "Protect nginx ingress"

  # Rule to allow traffic from Taiwan
  rule {
    action      = "allow"
    priority    = 100
    description = "Allow traffic from Taiwan"

    match {
      expr {
        expression = "origin.region_code == 'TW'"
      }
    }
  }

  # Default rule to deny all other traffic
  rule {
    action      = "deny(403)" # Deny with a 403 Forbidden status
    priority    = 2147483647
    description = "Default rule, deny all other traffic"

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"] # This matches all IPs
      }
    }
  }
}

resource "google_storage_bucket" "infra_outputs" {
  name          = "${local.project_id}-infra-output"
  location      = "US"
  force_destroy = true
}

output "cloudarmor_policy_name" {
  value       = google_compute_security_policy.nginx.name
  description = "The name of the Cloud Armor security policy."
}

output "infra_outputs_bucket" {
  value       = google_storage_bucket.infra_outputs.name
  description = "The name of the GCS bucket for infrastructure outputs."
}