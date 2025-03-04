resource "google_project_service" "funcao_apis_necessarias" {
  for_each = toset([
    "cloudfunctions.googleapis.com",
    "storage.googleapis.com",
    "cloudbuild.googleapis.com",
    "eventarc.googleapis.com",
    "run.googleapis.com"
  ])
  
  service            = each.key
  disable_on_destroy = false
}


resource "google_project_service" "service_usage_api" {
  service = "serviceusage.googleapis.com"
  disable_on_destroy = false
}


resource "google_storage_bucket_object" "funcao_script" {
  name   = "scripts/function-source.zip"
  bucket = google_storage_bucket.lake.name
  source = "../function-source.zip"
  depends_on = [google_storage_bucket.lake]
}


resource "google_cloudfunctions2_function" "funcao_ingest" {
  name = "${var.project_id}-funcao_ingest"
  location = var.gcp_region
  description = "Processa novos arquivos do bucket ${google_storage_bucket.lake.name}"

  build_config {
    runtime = "python312"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.lake.name
        object = google_storage_bucket_object.funcao_script.name
      }
    }
  }

  service_config {
    available_memory      = "512M"
    timeout_seconds       = 60
    service_account_email = google_service_account.contaservico.email
    environment_variables = {
      BUCKET_NAME = google_storage_bucket.lake.name
      DATASET_ID  = google_bigquery_dataset.dataset_dw.dataset_id
      PROJECT_ID  = var.project_id
    }
  }

  labels = {
      environment = var.environment
      project_id  = var.project_id
      pipeline    = "ingestao-dados"
    }

  depends_on = [
    google_project_service.funcao_apis_necessarias,
    google_storage_bucket_iam_member.permissao_admin_bucket,
    google_bigquery_dataset.dataset_dw
  ]
}

# Novo recurso para configurar o trigger do Eventarc
resource "google_eventarc_trigger" "storage_trigger" {
  name     = "${var.project_id}-storage-trigger"
  location = var.gcp_region
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.storage.object.v1.finalized"
  }
  matching_criteria {
    attribute = "bucket"
    value     = google_storage_bucket.lake.name
  }
  destination {
    cloud_run_service {
      service = google_cloudfunctions2_function.funcao_ingest.name
      region  = var.gcp_region
    }
  }
  service_account = google_service_account.contaservico.email
  depends_on = [
    google_project_service.funcao_apis_necessarias,
    google_cloudfunctions2_function.funcao_ingest,
    google_project_iam_member.permissao_eventarc
  ]
}
