#!/bin/bash
set -euo pipefail

echo "▶ Installing yq and Helm"
curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.43.1/yq_linux_amd64
chmod +x /usr/local/bin/yq
curl -sLo helm.tar.gz https://get.helm.sh/helm-v3.14.2-linux-amd64.tar.gz
tar -xzf helm.tar.gz
mv linux-amd64/helm /usr/local/bin/helm

echo "▶ Downloading cloudarmor.json from GCS"
gsutil cp gs://$1-infra-output/terraform/cloudarmor.json cloudarmor.json

echo "▶ Extracting Cloud Armor policy name"
POLICY_NAME=$(yq e '.cloudarmor_policy_name.value' cloudarmor.json)

# Strip double quotes from POLICY_NAME ---
POLICY_NAME="${POLICY_NAME//\"/}"

if [ -z "$POLICY_NAME" ]; then
  echo "Error: Failed to extract POLICY_NAME from cloudarmor.json"
  exit 1
fi
echo "Cloud Armor policy name: $POLICY_NAME"

echo "▶ Running Helm upgrade/install"
helm upgrade --install nginx ./helm/nginx \
  --set ingress.enabled=true \
  --set ingress.host=staging.nginx.9young.xyz \
  --set ingress.annotations."kubernetes\.io/ingress\.class"=gce \
  --set ingress.annotations."networking\.gke\.io/security-policy"="${POLICY_NAME}" \
  --set image.repository=us-central1-docker.pkg.dev/$1/${2}/${3} \
  --set image.tag=$4

echo "✅ Deployment complete."

echo "▶ Enforcing Cloud Armor policy on all GKE-created backend services"
BACKENDS=$(gcloud compute backend-services list --global --format="value(name)" | grep k8s1-)

for BACKEND in $BACKENDS; do
  echo "🔍 Checking backend service: $BACKEND"
  EXISTING_POLICY=$(gcloud compute backend-services describe "$BACKEND" --global --format="value(securityPolicy)")

  if [[ "$EXISTING_POLICY" != "$POLICY_NAME" ]]; then
    echo "🔗 Attaching Cloud Armor policy to $BACKEND"
    gcloud compute backend-services update "$BACKEND" \
      --global \
      --security-policy="$POLICY_NAME"
  else
    echo "✅ $BACKEND already has the correct policy attached"
  fi
done
set -e  # Re-enable strict error checking for other parts

echo "🎉 Cloud Armor policy enforcement complete."
exit 0