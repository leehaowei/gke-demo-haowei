resource "google_compute_security_policy" "nginx" {
  name        = "nginx-cloud-armor-policy"
  description = "Protect nginx ingress"

  # Rule to block traffic from India
  rule {
    action      = "deny(403)"
    priority    = 100
    description = "Block traffic from India"

    match {
      expr {
        expression = "origin.region_code == 'IN'"
      }
    }
  }

  # Default rule to allow all other traffic
  rule {
    action      = "allow"
    priority    = 2147483647
    description = "Default rule, allow all other traffic"

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
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