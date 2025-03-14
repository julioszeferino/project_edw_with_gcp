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


resource "google_project_iam_member" "permissao_eventarc_invoker" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.contaservico.email}"
}


resource "google_cloudfunctions2_function_iam_member" "permissao_invoker" {
  project        = google_cloudfunctions2_function.funcao_ingest.project
  location       = google_cloudfunctions2_function.funcao_ingest.location
  cloud_function = google_cloudfunctions2_function.funcao_ingest.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_service_account.contaservico.email}"
  depends_on = [ google_cloudfunctions2_function.funcao_ingest]
}


resource "google_cloud_run_service_iam_member" "eventarc_invoker" {
  location = var.gcp_region
  project  = var.project_id
  service  = google_cloudfunctions2_function.funcao_ingest.service_config[0].service

  role   = "roles/run.invoker"
  member = "serviceAccount:${google_service_account.contaservico.email}"
  depends_on = [ google_cloudfunctions2_function.funcao_ingest]
}