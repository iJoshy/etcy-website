variable "project_id" {
  description = "The GCP project ID to deploy into."
  type        = string
}

variable "region" {
  description = "The GCP region for Artifact Registry and Cloud Run."
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "The Cloud Run service name."
  type        = string
  default     = "etcy-website"
}

variable "artifact_repo" {
  description = "The Artifact Registry Docker repository name."
  type        = string
  default     = "etcy-website"
}

variable "image" {
  description = "The full container image URL to deploy."
  type        = string
}

variable "allow_unauthenticated" {
  description = "Whether the Cloud Run service is publicly reachable."
  type        = bool
  default     = true
}
