#!/bin/bash
# Configure Nextcloud for IONOS AI Model Hub image generation
# Run this after Nextcloud is deployed and healthy
#
# Usage:
#   IONOS_AI_TOKEN=your-token ./setup-ai-apps.sh
#   Or: kubectl exec -it <nextcloud-pod> -- bash -c "..."

set -euo pipefail

NAMESPACE="${NAMESPACE:-nextcloud}"
IONOS_AI_TOKEN="${IONOS_AI_TOKEN:-}"
IONOS_AI_URL="https://openai.inference.de-txl.ionos.com/v1"
IMAGE_MODEL="black-forest-labs/FLUX.1-schnell"

if [[ -z "$IONOS_AI_TOKEN" ]]; then
  echo "Error: IONOS_AI_TOKEN is required"
  echo "Usage: IONOS_AI_TOKEN=your-token ./setup-ai-apps.sh"
  exit 1
fi

# Get the Nextcloud pod name
POD=$(kubectl get pod -n "$NAMESPACE" -l app.kubernetes.io/name=nextcloud -o jsonpath='{.items[0].metadata.name}')
echo "Using pod: $POD"

echo "Installing Nextcloud apps..."
kubectl exec -n "$NAMESPACE" "$POD" -- php occ app:install assistant || echo "(assistant already installed)"
kubectl exec -n "$NAMESPACE" "$POD" -- php occ app:install integration_openai || echo "(integration_openai already installed)"

echo "Enabling apps..."
kubectl exec -n "$NAMESPACE" "$POD" -- php occ app:enable assistant
kubectl exec -n "$NAMESPACE" "$POD" -- php occ app:enable integration_openai

echo "Configuring IONOS AI Model Hub endpoint..."
kubectl exec -n "$NAMESPACE" "$POD" -- php occ config:app:set integration_openai url \
  --value="$IONOS_AI_URL"

kubectl exec -n "$NAMESPACE" "$POD" -- php occ config:app:set integration_openai api_key \
  --value="$IONOS_AI_TOKEN"

kubectl exec -n "$NAMESPACE" "$POD" -- php occ config:app:set integration_openai image_generation_model \
  --value="$IMAGE_MODEL"

echo "Enabling image generation in Assistant..."
kubectl exec -n "$NAMESPACE" "$POD" -- php occ config:app:set assistant \
  text_to_image_picker_enabled --value=1 --type=string

echo ""
echo "Done. IONOS AI Model Hub image generation is now active in Nextcloud."
echo "Users can access it via: Files → + → Generate image (or via the Assistant)"
