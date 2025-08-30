variable "project_id" {
  description = "The GCP project ID to deploy the MoStar Grid into."
  type        = string
}

variable "region" {
  description = "The GCP region to build the sovereign infrastructure."
  type        = string
  default     = "us-central1"
}
