# Etcy Website Deployment

Simple steps to overwrite the current website on Google Cloud Run.

## Current Cloud Run Service

- Project: `etcy-systems-prod`
- Region: `europe-west1`
- Service name: `etcy-website`
- Artifact Registry repo: `etcy-website`
- Current URL: `https://etcy-website-92604112727.europe-west1.run.app`

## Deploy

Run these commands from the project root:

```bash
cd /Users/mac/Projects/etcy-website
```

Make sure Google Cloud is using the right project:

```bash
gcloud config set project etcy-systems-prod
```

Create an image name:

```bash
TAG=$(date +%Y%m%d%H%M%S)
IMAGE="europe-west1-docker.pkg.dev/etcy-systems-prod/etcy-website/etcy-website:${TAG}"
```

Build and push the image to the existing Artifact Registry repo:

```bash
gcloud builds submit --tag "$IMAGE" .
```

Deploy that image to the existing Cloud Run service:

```bash
gcloud run deploy etcy-website \
  --image "$IMAGE" \
  --region europe-west1 \
  --allow-unauthenticated
```

When prompted, confirm the deployment.

Do not use `gcloud run deploy --source .` for this project unless you are okay with Google creating or using a separate repo named `cloud-run-source-deploy`.

## Check The Deployment

Open the live site:

```bash
open https://etcy-website-92604112727.europe-west1.run.app
```

Or check it from the terminal:

```bash
curl -I https://etcy-website-92604112727.europe-west1.run.app
```

Expected result:

```text
HTTP/2 200
```

## If You Need To Confirm The Active URL

```bash
gcloud run services describe etcy-website \
  --region europe-west1 \
  --format="value(status.url)"
```

## What This Deploys

Cloud Run builds and deploys this repo using:

- `Dockerfile`
- `nginx.conf`
- `index.html`

So after editing `index.html`, just run the deploy command again.
