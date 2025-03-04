resource "google_service_account" "contaservico" {
  account_id  = "${var.project_id}-sa"
  description = "Conta servico para execucao do pipeline"
}


resource "google_storage_bucket_iam_member" "permissao_admin_bucket" {
  bucket = google_storage_bucket.lake.name
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.contaservico.email}"
  depends_on = [
    google_service_account.contaservico,
    google_storage_bucket.lake
  ]
}


resource "google_project_iam_member" "permissao_admin_bigquery" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.contaservico.email}"
  depends_on = [google_service_account.contaservico]
}


resource "google_project_iam_member" "permissao_user_bigquery" {
  project = var.project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.contaservico.email}"
  depends_on = [google_service_account.contaservico]
}


resource "google_cloud_run_service_iam_member" "permissao_exec_function" {
  location = google_cloudfunctions2_function.funcao_ingest.location
  service  = google_cloudfunctions2_function.funcao_ingest.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.contaservico.email}"
  depends_on = [
    google_cloudfunctions2_function.funcao_ingest,
    google_service_account.contaservico,
    google_eventarc_trigger.storage_trigger
  ]
}


resource "google_project_iam_member" "permissao_eventarc" {
  project = var.project_id
  role    = "roles/eventarc.admin"
  member  = "serviceAccount:${google_service_account.contaservico.email}"
}

resource "google_project_iam_member" "permissao_service_agent" {
  project = var.project_id
  role    = "roles/cloudfunctions.serviceAgent"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudfunctions.iam.gserviceaccount.com"
}

data "google_project" "project" {}

resource "google_project_iam_member" "permissao_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.contaservico.email}"
}

