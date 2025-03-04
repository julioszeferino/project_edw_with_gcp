resource "google_bigquery_dataset" "dataset_dw" {
  dataset_id                  = var.dataset_name
  friendly_name               = "Business Data Warehouse"
  description                 = "Armazena dados processados dos arquivos do Cloud Storage"
  location                    = var.gcp_region
  default_table_expiration_ms = 604800000  # 7 dias

  labels = {
    environment = var.environment,
    project_id  = var.project_id
    pipeline = "ingestao-dados"
  }

  # Permissões via IAM (mais seguro)
  depends_on = [
    google_project_service.funcao_apis_necessarias
  ]
}


resource "google_bigquery_table" "tabela_vendas" {
  dataset_id = google_bigquery_dataset.dataset_dw.dataset_id
  table_id   = "vendas"
  deletion_protection=false

  schema = <<EOF
[
  {
    "name": "numero_venda",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "nota_fiscal_rps",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "cliente_vendedor",
    "mode": "NULLABLE",
    "type": "STRING",
    "description": "",
    "fields": []
  },
  {
    "name": "data_venda",
    "mode": "NULLABLE",
    "type": "DATE",
    "description": "",
    "fields": []
  },
  {
    "name": "valor_bruto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "valor_liquido_sem_frete",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "anomes",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  }
]
EOF

  labels = {
    environment = var.environment,
    project_id  = var.project_id
    pipeline = "ingestao-dados"
  }
}


resource "google_bigquery_table" "tabela_fluxo_caixa" {
  dataset_id = google_bigquery_dataset.dataset_dw.dataset_id
  table_id   = "fluxo_caixa"
  deletion_protection=false

  schema = <<EOF
[
  {
    "name": "categorias",
    "mode": "NULLABLE",
    "type": "STRING",
    "description": "",
    "fields": []
  },
  {
    "name": "JAN_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "JAN_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "FEV_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "FEV_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "MAR_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "MAR_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "ABR_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "ABR_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "MAI_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "MAI_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "JUN_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "JUN_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "JUL_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "JUL_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "AGO_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "AGO_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "SET_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "SET_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "OUT_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "OUT_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "NOV_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "NOV_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "DEZ_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "DEZ_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "Total_previsto",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "Total_realizado",
    "mode": "NULLABLE",
    "type": "FLOAT",
    "description": "",
    "fields": []
  },
  {
    "name": "ano",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  }
]
EOF

  labels = {
    environment = var.environment,
    project_id  = var.project_id
    pipeline = "ingestao-dados"
  }
}


resource "google_bigquery_table" "tabela_dre" {
  dataset_id = google_bigquery_dataset.dataset_dw.dataset_id
  table_id   = "dre"
  deletion_protection=false

  schema = <<EOF
[
  {
    "name": "Categoria",
    "mode": "NULLABLE",
    "type": "STRING",
    "description": "",
    "fields": []
  },
  {
    "name": "Janeiro",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "Fevereiro",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "Março",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "Abril",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "Maio",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "Junho",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "Julho",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "Agosto",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "Setembro",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "Outubro",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "Novembro",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "Dezembro",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "Total",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  },
  {
    "name": "ano",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "",
    "fields": []
  }
]
EOF

  labels = {
    environment = var.environment,
    project_id  = var.project_id
    pipeline = "ingestao-dados"
  }
}
