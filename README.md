# 🌐 GKE NGINX Demo Project

> A hands-on demonstration of deploying an NGINX server on Google Kubernetes Engine (GKE) using Terraform, Helm, Cloud Build, and Cloud Armor in a GitOps-driven CI/CD pipeline.

---

## 📖 Overview

This project showcases a modern DevOps workflow for deploying a containerized NGINX application to GKE. It integrates **Terraform** for infrastructure provisioning, **Helm** for Kubernetes deployments, **Cloud Build** for CI/CD automation, and **Cloud Armor** for security. The pipeline follows GitOps principles, with environment-specific deployments for `dev` and `staging`.

Key features:
- Automated GCP infrastructure setup via Terraform
- Containerized NGINX app deployed via Helm
- CI/CD pipeline using Cloud Build with environment-specific triggers
- Geo-based security with Cloud Armor
- Preserved Kustomize structure for reference

> **Note**: This project is for **demonstration and educational purposes only**. It omits production-grade features like advanced logging, autoscaling, and well crafted commits following Conventional Commits .

---

## 🛠️ Technologies Used

- **Google Kubernetes Engine (GKE)**: Managed Kubernetes cluster
- **Terraform**: Infrastructure as Code (IaC) for GCP resources
- **Helm**: Kubernetes package management
- **Cloud Build**: CI/CD pipeline automation
- **Cloud Armor**: Security policy enforcement
- **Docker**: Containerization
- **Kustomize**: Preserved for base/overlay structure (legacy)

---

## ✅ Testing & Verification

Test the deployment using a real domain:
- **URL**: [`staging.nginx.9young.xyz/sre.txt`](http://staging.nginx.9young.xyz/sre.txt)
- **Behavior**:
  - ✅ **From Taiwan**: Returns `200 OK` with `Hello SRE!`
  - ❌ **From outside Taiwan (e.g., via VPN)**: Returns `403 Forbidden` due to Cloud Armor geo-blocking
- **DNS**: Configured via GoDaddy, pointing to the GKE Ingress IP provisioned by Terraform and Helm
---

## 🔒 Security with Cloud Armor

The Cloud Armor policy enforces geo-based access control:
- ✅ **Allow**: Traffic from Taiwan (`origin.region_code == 'TW'`)
- ❌ **Deny**: All other sources

The policy is applied to the GKE Ingress backend service to protect the NGINX application.

---

## 🚀 Deployment Workflow

The CI/CD pipeline is triggered by pushes to `staging` or `main` (dev)  branches or manually via the Cloud Console. Each branch maps to a specific `cloudbuild.yaml` file:

**Pipeline Steps**:
1. Build and push Docker image to Artifact Registry
2. Deploy NGINX via Helm
3. Apply Cloud Armor policy to the GKE Ingress backend

`staging` branch is chosen to be the default branch for final demonstration

---

## 📘 Technical Design Choices

### Why Helm Over Kustomize?
Kustomize was initially used for environment-specific manifests (`base/` and `overlays/`). However, limitations in applying Cloud Armor annotations to GKE Ingress led to adopting **Helm** for better control over annotations and deployment hooks. The Kustomize structure is preserved for reference and potential future use.

### Cloud Armor Integration
To address race conditions between Helm deployments and Cloud Armor policy application:
1. Terraform creates the Cloud Armor policy and uploads its name to a `cloudarmor.json` file in GCS.
2. The `scripts/deploy.sh` script:
  - Downloads `cloudarmor.json`
  - Injects the policy name into Helm Ingress annotations
  - Uses `gcloud compute backend-services update` to enforce the policy on backend services

---

## 🤯 Challenges & Solutions

### 1. Infrastructure Bootstrapping (Terraform)
- **Challenge**: Ensuring clean VPC deletion without conflicts from GKE or Network Endpoint Groups (NEGs).
- **Solution**: Ordered resource cleanup in Terraform to avoid errors like:
  ```
  Error: Error waiting for Deleting Network: The network resource ... is already being used by ...
  ```
- **Lesson**: Always destroy dependent resources (e.g., GKE clusters, NEGs) before VPCs.

### 2. CI/CD Tool Selection
- **Challenge**: Choosing between Jenkins, GitHub Actions, and Cloud Build. GitHub Actions struggled with GCP resource access, and Jenkins required extensive setup.
- **Solution**: Adopted **Cloud Build** for native GCP integration and seamless GitHub triggers.
- **Lesson**: Native tools reduce configuration overhead for cloud-specific workflows.

### 3. Cloud Armor and GKE Ingress
- **Challenge**: GKE Ingress annotations (`networking.gke.io/security-policy`) did not reliably attach Cloud Armor policies due to race conditions.
- **Solution**: Used Terraform to pre-create the policy, stored it in GCS, and applied it via Helm annotations and `gcloud` commands.
- **Lesson**: Explicit backend service updates ensure reliable policy enforcement.

### 4. IAM Configuration
- **Challenge**: Configuring IAM roles for Cloud Build to access GCP resources.
- **Solution**: Defined precise IAM roles in Terraform, leveraging AI assistance to identify correct roles.
- **Lesson**: Granular IAM policies are critical for secure CI/CD pipelines.

---

## 🔁 Future Improvements

- 🔐 Implement HTTPS with managed SSL certificates
- 📊 Add monitoring and logging (e.g., Cloud Logging, Prometheus)
- 🔄 Introduce ArgoCD or Flux for advanced GitOps workflows
- ✅ Split app and infrastructure into separate repositories

---

## 🧰 Project Structure

```
.
├── Dockerfile                 # NGINX container definition
├── cloudbuild.yaml            # CI/CD pipeline for dev
├── cloudbuild.staging.yaml    # CI/CD pipeline for staging
├── scripts/
│   └── deploy.sh              # Helm deployment and Cloud Armor integration
├── helm/
│   └── nginx/                 # Helm chart for NGINX
├── base/                      # Kustomize base manifests (legacy)
├── overlays/                  # Kustomize environment overlays
├── terraform/                 # GCP infrastructure as code
```

---

## 🌍 References

- [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Cloud Build](https://cloud.google.com/build)
- [Create GKE Cluster using Terraform](http://www.youtube.com/@AntonPutra)


---

## 🙏 Acknowledgments

This project was built with assistance from AI tools (e.g., ChatGPT) for:
- Designing Cloud Armor policies
- Troubleshooting GKE Ingress issues
- Optimizing Cloud Build pipelines