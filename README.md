### Bootstrap up the GCP infra
- `cd terraform`
- `terraform plan`
- `terraform apply`

### Steps to run nginx locally
- Builds and runs the container
`make run`     

- Once the container is running, open your browser or use curl
`curl http://localhost:8080/sre.txt`

### Expose nginx server as service
- use Kustomize to deploy the manifest 
`kubectl apply -k overlays/dev/`
- Inspect the deployment
`kubectl get deployment -n demo-dev`
- Inspect the service and fetch the `EXTERNAL-IP`
`kubectl get svc -n demo-dev`
- example
    ```
    NAME    TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
    nginx   LoadBalancer   172.20.60.94   35.222.212.217   80:31326/TCP   72s
    ```
- verify the result
`curl http://35.222.212.217/sre.txt`
- destroy the resource
`kubectl delete -k overlays/dev/`

### Inspect the current version
use the command below to check the current image version/tag
`kubectl get deployment nginx -n demo -o yaml | grep image:`

### GitOps with Cloud Build, Kustomize & Terraform
This repository follows a GitOps approach by linking each Git branch to a Kubernetes environment (dev, staging, etc.), using Cloud Build triggers and Kustomize overlays.

| Git Branch | Kustomize Overlay  | GKE Namespace | Triggered Pipeline        |
| ---------- | ------------------ | ------------- | ------------------------- |
| `main`     | `overlays/dev`     | `dev`         | `cloudbuild.yaml`         |
| `staging`  | `overlays/staging` | `staging`     | `cloudbuild.staging.yaml` |

Directory Structure
```declarative
base/                   # Base manifests shared across all environments
overlays/
  dev/                  # Kustomize overlay for dev environment
  staging/              # Kustomize overlay for staging environment
terraform/              # Infra as Code (Cloud Build, GKE, Artifact Registry, etc.)
cloudbuild.yaml         # CI/CD pipeline for dev
cloudbuild.staging.yaml # CI/CD pipeline for staging
```