import os
import re
from google.cloud import storage, bigquery
import functions_framework
import logging
import io

# Configuração de logging
logging.basicConfig(level=logging.INFO)


BUCKET_NAME = os.getenv('BUCKET_NAME')
DATASET_ID = os.getenv('DATASET_ID')


def extract_table_and_anomes(file_name):
    """
    Extrai o nome da tabela e o anomes do nome do arquivo.
    Formatos aceitos:
    - Com mês: vendas/2025/VENDAS_012025.csv → MMAAAA (anomes=012025)
    - Sem mês: vendas/2025/VENDAS_2025.csv → AAAA (anomes=2025)
    """
    # Regex para capturar ambos os formatos (com ou sem mês)
    match = re.search(
        r".*/(.*?)_((\d{2})(\d{4})|(\d{4}))\.csv$",  # Aceita MMYYYY ou YYYY
        file_name
    )
    
    if not match:
        print(f"Arquivo {file_name} não segue o padrão esperado. Ignorando.")
        return None, None, None  # Retorna None para todos os valores

    table_name = match.group(1).strip().lower()  # Nome da tabela (ex: 'vendas')
    month = match.group(3)  # Grupo 3: mês (MM) se existir
    year = match.group(4) or match.group(5)  # Grupo 4 (YYYY) ou 5 (YYYY)

    if month and year:
        anomes = f"{year}{month}"  # Formato AAAAMM
        col_ref = 'anomes'
    elif year:
        anomes = f"{year}"  # Formato AAAA
        col_ref = 'ano'
    else:
        print(f"Formato inválido para {file_name}.")
        return None, None, None

    return table_name, anomes, col_ref


def delete_existing_anomes(table_name, anomes, bq_client, col_ref):
    """
    Deleta os registros da tabela que correspondem à competência (anomes).
    """
    query = f"""
        DELETE FROM `{DATASET_ID}.{table_name}`
        WHERE {col_ref} = {anomes};
    """
    job = bq_client.query(query)
    job.result()  # Aguarda a conclusão da query
    print(f"Registros da competência {anomes} deletados da tabela {table_name}.")

    
def process_file(file_name, storage_client, bq_client):
    """
    Processa um arquivo CSV, insere os dados no BigQuery e renomeia o arquivo.
    """
    try:
        # Extrai o nome da tabela e o anomes do nome do arquivo
        table_name, anomes, col_ref = extract_table_and_anomes(file_name)
        if not table_name or not anomes:
            return

        logging.info(f"Verifica se a competência {anomes} já existe na tabela {DATASET_ID}.{table_name}.")
        query = f"""
            SELECT COUNT(*) as total
            FROM `{DATASET_ID}.{table_name}`
            WHERE {col_ref} = {anomes};
        """
        query_job = bq_client.query(query)
        result = query_job.result()
        row = next(result)
        if row.total > 0:
            logging.info(f"Competência {anomes} já existe na tabela {table_name}. Deletando registros...")
            delete_existing_anomes(table_name, anomes, bq_client, col_ref)


        # Lê o arquivo do GCS
        logging.info(f"Lendo o arquivo {BUCKET_NAME}/{file_name}")
        bucket = storage_client.bucket(BUCKET_NAME)
        blob = bucket.blob(file_name)
        data = blob.download_as_text()

        logging.info(f"Adiciona a coluna anomes aos dados")
        lines = data.splitlines()
        header = lines[0] + f",{col_ref}"
        rows = [f"{line},{anomes}" for line in lines[1:]]
        # row = io.StringIO("\n".join(rows))

        csv_data = "\n".join(rows).encode("utf-8")
        row = io.BytesIO(csv_data) 

        table_ref = bq_client.dataset(DATASET_ID.split('.')[1]).table(table_name)

        job_config = bigquery.LoadJobConfig(
            source_format=bigquery.SourceFormat.CSV,
            skip_leading_rows=0,
            # autodetect=True,
            field_delimiter=',',
            encoding='UTF-8',
            write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        )

        logging.info(f"Insere os dados no BigQuery: {DATASET_ID}.{table_name}")
        job = bq_client.load_table_from_file(
            row,
            table_ref,
            job_config=job_config,
        )
        job.result()  

        logging.info(f"Dados do arquivo {file_name} inseridos na tabela {table_name} do BigQuery.")

        # Renomeia o arquivo para adicionar o sufixo _SUCCESS
        new_name = file_name.replace(".csv", "_SUCCESS.csv")
        bucket.rename_blob(blob, new_name)
        logging.info(f"Arquivo {file_name} renomeado para {new_name}.")

    except Exception as e:
        logging.error(f"Erro ao processar o arquivo {file_name}: {str(e)}")


def process_folder(folder_name, storage_client, bq_client):
    # Lista todos os arquivos na pasta e subpastas
    bucket = storage_client.bucket(BUCKET_NAME)
    blobs = bucket.list_blobs(prefix=folder_name)

    for blob in blobs:
        if not blob.name.endswith("_SUCCESS.csv") and blob.name.endswith(".csv"):
            print(f"Processando arquivo: {blob.name}")
            process_file(blob.name, storage_client, bq_client)


@functions_framework.http
def main(request):
    """
    Função principal acionada via HTTP.
    """
    try:
        # Inicializa os clientes do GCS e BigQuery
        storage_client = storage.Client()
        bq_client = bigquery.Client()

        # Obtém o nome do arquivo da requisição
        request_json = request.get_json(silent=True)
        request_args = request.args

        if request_json and 'name' in request_json:
            file_name = request_json['name']
        elif request_args and 'name' in request_args:
            file_name = request_args['name']
        else:
            logging.error("Nome do arquivo não fornecido na requisição.")
            return "Nome do arquivo não fornecido.", 400

        # Processa o arquivo
        if not file_name.endswith("_SUCCESS.csv") and file_name.endswith(".csv"):
            logging.info(f"Processando arquivo: {file_name}")
            process_file(file_name, storage_client, bq_client)
            return "Arquivo processado com sucesso.", 200
        else:
            logging.warning(f"Arquivo {file_name} ignorado (já processado ou formato inválido).")
            return "Arquivo ignorado.", 200

    except Exception as e:
        logging.error(f"Erro na função principal: {str(e)}")
        return f"Erro interno: {str(e)}", 500
