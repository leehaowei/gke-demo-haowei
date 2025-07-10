variable "private_pool_name" {
  description = "A unique name for your Cloud Build Private Pool."
  type        = string
  default     = "gke-deploy-private-pool" # This should match the name used in cloudbuild.yaml
}