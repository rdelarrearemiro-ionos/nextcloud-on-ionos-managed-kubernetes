# AI Image Generation with IONOS AI Model Hub

This guide extends the base Nextcloud deployment with AI image generation powered by
[IONOS AI Model Hub](https://docs.ionos.com/cloud/ai/ai-model-hub) — running entirely
on IONOS infrastructure, with data processed in Germany.

## How it works

```
Nextcloud UI (Assistant)
        │
        ▼
integration_openai app
        │  OpenAI-compatible API
        ▼
IONOS AI Model Hub
https://openai.inference.de-txl.ionos.com/v1/images/generations
        │
        ▼
FLUX.1-schnell (black-forest-labs)
```

Nextcloud's `integration_openai` app connects to any OpenAI-compatible endpoint.
IONOS AI Model Hub exposes exactly that interface — no custom code required.
Generated images are saved directly into the user's Nextcloud storage.

## Model

**FLUX.1-schnell** (`black-forest-labs/FLUX.1-schnell`)
- Fast, high-quality text-to-image generation
- Rate limit: 10 images/min (burst: 20/min)
- Prompt max length: 256 characters
- Multilingual prompts supported
- Data processed in Germany (GDPR-friendly)

## Prerequisites

- Nextcloud deployed and healthy (see main README)
- IONOS AI Model Hub API token

## Step 1 — Create an IONOS AI Model Hub API token

1. Log in to [IONOS DCD](https://dcd.ionos.com)
2. Go to **AI Model Hub** → **Access Management** → **API Tokens**
3. Create a new token and copy it

## Step 2 — Store the token as a Kubernetes secret

```bash
cp manifests/06-ai-model-hub/ai-token-secret.yaml.example \
   manifests/06-ai-model-hub/ai-token-secret.yaml

# Edit and replace YOUR_IONOS_AI_MODEL_HUB_TOKEN
kubectl apply -f manifests/06-ai-model-hub/ai-token-secret.yaml
```

## Step 3 — Install and configure Nextcloud apps

```bash
chmod +x manifests/06-ai-model-hub/setup-ai-apps.sh
IONOS_AI_TOKEN=your-token ./manifests/06-ai-model-hub/setup-ai-apps.sh
```

This script:
1. Installs the `assistant` and `integration_openai` Nextcloud apps
2. Points `integration_openai` at `https://openai.inference.de-txl.ionos.com/v1`
3. Sets `black-forest-labs/FLUX.1-schnell` as the image model
4. Enables the image generation picker in the Assistant

## Step 4 — Generate your first image

1. Log in to Nextcloud as any user
2. Click **+** (new file) in the Files app → **Generate image**
   — or open the **Assistant** (top bar ✨ icon) → **Generate image**
3. Enter a prompt (max 256 characters), e.g.:
   `A photorealistic sunset over the Atlantic Ocean, warm golden light`
4. The generated image is saved to your Nextcloud Files automatically

## Verify the API directly (optional)

Test the IONOS endpoint before configuring Nextcloud:

```bash
curl -s https://openai.inference.de-txl.ionos.com/v1/images/generations \
  -H "Authorization: Bearer YOUR_IONOS_AI_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "black-forest-labs/FLUX.1-schnell",
    "prompt": "A mountain lake at dawn",
    "size": "1024x1024"
  }' | python3 -m json.tool
```

The response contains a `data[].b64_json` field with the base64-encoded image.

## List all available models

```bash
curl -s https://openai.inference.de-txl.ionos.com/v1/models \
  -H "Authorization: Bearer YOUR_IONOS_AI_TOKEN" | python3 -m json.tool
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| "No image generation provider" in Nextcloud | App not enabled | Re-run `setup-ai-apps.sh` |
| 401 Unauthorized from IONOS API | Wrong token | Check token in DCD → AI Model Hub |
| 429 Too Many Requests | Rate limit hit | Wait 1 minute (10 img/min limit) |
| Prompt ignored / bad output | Prompt > 256 chars | Shorten the prompt |
