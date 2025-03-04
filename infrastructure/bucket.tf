resource "google_storage_bucket" "lake" {

  name          = "${var.project_id}-${var.bucket_name}" 
  location      = var.gcp_region
  storage_class = "STANDARD"
  force_destroy = var.environment == "prod" ? false : true 
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true
  
  hierarchical_namespace {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 1095 # 3 anos
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment,
    project_id  = var.project_id
    pipeline = "ingestao-dados"
  }

}
