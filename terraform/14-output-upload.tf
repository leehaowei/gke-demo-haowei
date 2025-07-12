resource "null_resource" "upload_outputs" {
  provisioner "local-exec" {
    command = <<EOT
      terraform output -json > cloudarmor.json
      gsutil cp cloudarmor.json gs://${google_storage_bucket.infra_outputs.name}/terraform/cloudarmor.json
    EOT
  }

  depends_on = [
    google_compute_security_policy.nginx,
    google_storage_bucket.infra_outputs
  ]
}
