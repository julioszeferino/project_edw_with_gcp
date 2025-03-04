resource "google_project_service" "funcao_apis_necessarias" {
  for_each = toset([
    "cloudfunctions.googleapis.com",
    "storage.googleapis.com",
    "cloudbuild.googleapis.com",
    "eventarc.googleapis.com"
  ])
  
  service            = each.key
  disable_on_destroy = false
}


resource "google_storage_bucket_object" "funcao_script" {
  name   = "scripts/function-source.zip"
  bucket = google_storage_bucket.lake.name
  source = "../function-source.zip"
  depends_on = [google_storage_bucket.lake]
}


resource "google_cloudfunctions_function" "funcao_ingest" {
  name                  = "${var.project_id}-funcao_ingest"
  description           = "Processa novos arquivos do bucket ${google_storage_bucket.lake.name}"
  runtime               = "python312"
  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.lake.name
  source_archive_object = google_storage_bucket_object.funcao_script.name
  entry_point           = "main"
  service_account_email = google_service_account.contaservico.email
  timeout               = 60

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.lake.name
  }

  environment_variables = {
    BUCKET_NAME = google_storage_bucket.lake.name
    DATASET_ID = google_bigquery_dataset.dataset_dw.dataset_id
    PROJECT_ID  = var.project_id
  }

  depends_on = [
    google_project_service.funcao_apis_necessarias,
    google_storage_bucket_iam_member.permissao_admin_bucket,
    google_bigquery_dataset.dataset_dw
  ]

  labels = {
    environment = var.environment,
    project_id  = var.project_id
    pipeline = "ingestao-dados"
  }
}