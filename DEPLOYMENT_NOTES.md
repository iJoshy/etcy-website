# Etcy Website Deployment Notes

This file captures the Cloud Run deployment context so work can continue after closing the IDE.

## Current Deployment

- GCP project: `etcy-systems-prod`
- Region: `europe-west1`
- Cloud Run service: `etcy-website`
- Artifact Registry repo: `etcy-website`
- Cloud Run URL: `https://etcy-website-a4syzwgvmq-ew.a.run.app/`
- Custom domain to map: `etyc.systems`
- Custom www domain to map: `www.etyc.systems`

## Files Added

- `Dockerfile`
- `nginx.conf`
- `.dockerignore`
- `infra/terraform/versions.tf`
- `infra/terraform/variables.tf`
- `infra/terraform/main.tf`
- `infra/terraform/outputs.tf`
- `infra/terraform/.terraform.lock.hcl`

## Important Fixes Applied

- Added an Nginx container for the static `index.html` website.
- Added Terraform for Artifact Registry, Cloud Run, public invoker IAM, and required Google APIs.
- Set Cloud Run memory to `512Mi` because Cloud Run rejected `256Mi` with always-allocated CPU.
- Granted Cloud Build source-read permission for both possible builder service accounts:
  - `${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com`
  - `${PROJECT_NUMBER}-compute@developer.gserviceaccount.com`
- Granted Artifact Registry writer permissions to the same Cloud Build service accounts.
- Replaced the Nginx template config with a direct `nginx.conf` copied to `/etc/nginx/conf.d/default.conf`.
- Configured Nginx to listen on `8080`, the Cloud Run container port.
- Fixed `403 Forbidden` from Nginx by setting readable file permissions inside the image:
  - `chmod 0644 /etc/nginx/conf.d/default.conf /usr/share/nginx/html/index.html`
- Added Docker build checks:
  - `test -s /usr/share/nginx/html/index.html`
  - `nginx -t`

## Standard Deploy Commands

Run these from the repo root:

```bash
export PROJECT_ID="etcy-systems-prod"
export REGION="europe-west1"
export SERVICE_NAME="etcy-website"
export REPO="etcy-website"
export IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${SERVICE_NAME}:$(date +%Y%m%d%H%M%S)"

gcloud config set project "$PROJECT_ID"

gcloud builds submit --project "$PROJECT_ID" --tag "$IMAGE" .

terraform -chdir=infra/terraform apply -auto-approve \
  -var="project_id=${PROJECT_ID}" \
  -var="region=${REGION}" \
  -var="service_name=${SERVICE_NAME}" \
  -var="artifact_repo=${REPO}" \
  -var="image=${IMAGE}"
```

Get the Cloud Run URL:

```bash
terraform -chdir=infra/terraform output -raw service_url
```

Check the deployed service:

```bash
curl -I "$(terraform -chdir=infra/terraform output -raw service_url)/"
curl -i "$(terraform -chdir=infra/terraform output -raw service_url)/healthz"
```

Expected results:

- `/` returns `HTTP/2 200`
- `/healthz` returns `200 ok`

## Useful Debug Commands

Show the image Cloud Run is using:

```bash
gcloud run services describe "$SERVICE_NAME" \
  --project "$PROJECT_ID" \
  --region "$REGION" \
  --format="value(status.latestReadyRevisionName,spec.template.containers[0].image,status.url)"
```

Check public access:

```bash
gcloud run services get-iam-policy "$SERVICE_NAME" \
  --project "$PROJECT_ID" \
  --region "$REGION"
```

Read recent Cloud Run logs:

```bash
gcloud logging read 'resource.type="cloud_run_revision" AND resource.labels.service_name="etcy-website"' \
  --project "$PROJECT_ID" \
  --limit 50 \
  --format="value(timestamp,severity,textPayload)"
```

## Custom Domain Mapping

The purchased domain is `etyc.systems`.

Verify domain ownership:

```bash
gcloud domains list-user-verified
gcloud domains verify etyc.systems
```

Create Cloud Run domain mappings:

```bash
gcloud beta run domain-mappings create \
  --service etcy-website \
  --domain etyc.systems \
  --region europe-west1 \
  --project etcy-systems-prod

gcloud beta run domain-mappings create \
  --service etcy-website \
  --domain www.etyc.systems \
  --region europe-west1 \
  --project etcy-systems-prod
```

Get the DNS records to add at the registrar:

```bash
gcloud beta run domain-mappings describe \
  --domain etyc.systems \
  --region europe-west1 \
  --project etcy-systems-prod \
  --format=json

gcloud beta run domain-mappings describe \
  --domain www.etyc.systems \
  --region europe-west1 \
  --project etcy-systems-prod \
  --format=json
```

Add all returned `resourceRecords` to the domain registrar DNS settings.

Check DNS and HTTPS:

```bash
dig +short etyc.systems
dig +short www.etyc.systems
curl -I https://etyc.systems
curl -I https://www.etyc.systems
```

Final expected custom URLs:

- `https://etyc.systems`
- `https://www.etyc.systems`

## Resume Prompt

When reopening the IDE, ask:

```text
Please read DEPLOYMENT_NOTES.md and continue from where we left off.
```
