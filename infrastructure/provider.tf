terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.24.0"
    }
  }
}

provider "google" {
  # credentials = file("../credentials.json")
  project     = var.project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
}