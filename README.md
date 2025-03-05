# Enterprise DW com BigQuery

> Este pipeline foi criado com o objetivo de entregar um fluxo de dados funcional no gpc com baixo custo e que, a depender da volumetria, pode se encaixar no free-tier da GCP por um bom tempo.

- O Fluxo de dados é orientado a eventos. Os dados são movimentados para o DW à medida que chegam ao bucket.
- O pipeline utiliza uma função no `Cloud Run` para servir como "listener" e realizar a inserção dos dados no bigquery.
- Os dados de entrada são armazenados no `GCP Storage`
- Os dados são armazenados no `BigQuery`.
- Toda a execução do projeto é orquestrada pelo `GCP Cloud Functions`.
- Ao final, a análise dos dados é disponibilizada via `Looker`.
  

![](/docs/assets/arquitetura_dados.png)

## Stack de Tecnologias
[Google BigQuery](https://cloud.google.com/bigquery)  
[Google Storage](https://cloud.google.com/storage)  
[Google Cloud Run](https://cloud.google.com/run)  
[Looker Data Studio](https://cloud.google.com/solutions/data-analytics-and-ai)  
[Python 3.12](https://www.python.org/)  
[Terraform](https://www.terraform.io/)  


## Decisões Arquiteturais do Projeto
- O projeto visa uma arquitetura de dados de **baixo custo**, projetada para iniciativas de **pequeno porte**, porém com **capacidade de escalonamento contínuo** conforme o aumento da volumetria e das demandas analíticas. A estrutura proposta serve como base para iniciativas de Business Intelligence (BI), combinando simplicidade operacional e preparação para evolução tecnológica.
- A escolha do `Google Cloud Storage` como camada de ingestão prioriza **redução de custos e flexibilidade**. O free-tier oferece 5GB gratuitos, ideal para cenários iniciais, com cobrança proporcional ao crescimento. Os dados são armazenados em formato bruto (CSV), organizados por tabelas e domínios, o que **mantém a fidelidade aos dados originais, facilita a transição para um modelo de lakehouse e permite uma gestão modular (ou por domínios), onde novos dados podem ser incorporados sem impactar pipelines existentes.**
- `Python` é a linguagem mais utilizada em projetos de dados, com bibliotecas consolidadas e compatibilidade com ecossistemas modernos. O modelo de computação sem servidor do `Cloud Run` complementa essa escolha com **custo adaptável, escalabilidade automática e orquestração via eventos**. No projeto, a escolha por um trigger que aciona a função à medida que os arquivos entram no storage torna a entrega dos dados ágil e dinâmica, alé de muito intuitiva.
- O Google `BigQuery` é um dos provedores de DW mais conhecidos do mercado. Escalável e facilmente integrado à maior parte das ferramentas de BI, sua performance e custo é uma das que mais trazem benefícios. O free-tier permite o armazenamento de até 30gb's gratuitos e o as queries são precificadas pelo uso.
- O `Looker` é a ferramenta de BI do GCP, mesmo que muito simples em termos de recursos, atende a maioria das necessidades de análise sem que seja necessário buscar ferramentas terceiras além de ter integração direta com o bigquery.
- Essa combinação entre custo inicial mínimo, tecnologias gerenciadas e abertura para inovações posiciona o projeto como uma solução sustentável, capaz de acompanhar a maturidade analítica da organização sem rupturas tecnológicas.


## Deploy da Infraestrutura
1. Crie um projeto e uma Conta de Serviço no GCP com permissão de criação dos recursos que vamos utilizar. Crie uma chave JSON e guarde as credenciais. Este [link](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build) indica como esse processo pode ser feito.  

2. Crie um bucket para guardar os dados do terraform.   

3. Configurações do Terraform.  
    3.1. Edite o arquivo `infrastructure/variables.tf` e edite o valor das variáveis.  
    ```yaml
    # id do projeto gcp
    variable "project_id" {
    default = "learning-gcp-julioszeferino"
    }

    # regiao onde os recursos serão criados
    variable "gcp_region" {
    default = "us-central1"
    }

    # nome do bucket que vai receber os dados da camada ingest
    variable "bucket_name" {
    default = "datalake"
    }

    # nome do banco do bigquery
    variable "dataset_name" {
    default = "warehouse"
    }
    ```
    3.2. Edite o arquivo  `infrastructure/provider.tf` e troque o nome do bucket para guardar os dados do terraform. Ele quem vai guardar o estado das ações de infra que serão executadas.
    ```yaml
    backend "gcs" {
        bucket  = "terraform-state-infra-julioszeferino"
        prefix  = "terraform/state"
    }
    ```
    3.3. Customize as tabelas que serão criadas no bigquery no arquivo `infrastructure/bigquery.tf`. Por padrão será criada a tabela vendas, dre e fluxo_caixa.

4. Edite os secrets do github workflows:
- GCP_PROJECT_ID: id do projeto no gcp
- GCP_SA_KEY: JSON que foi salvo quando criamos a conta de serviço

5. Quando realizar um commit na branch `master` todos os recursos serão criados. (Pode ser necessário a ativação de algumas APIS adicionais no GCP como a [Service Usage API](https://console.cloud.google.com/apis/library/serviceusage.googleapis.com?project=learning-gcp-julioszeferino&inv=1&invt=AbrK1Q) e a [Cloud Resource Manager API](https://console.cloud.google.com/apis/library/cloudresourcemanager.googleapis.com?project=learning-gcp-julioszeferino))

## Como Executar o Projeto
- O pipeline é orientado a eventos. Cria-se as pastas no bucket de acordo com as tabelas de domínio do negócio (uma pasta por tabela) e a medida que realizar upload dos arquivos no bucket a função do cloudrun será executada.
- O conector criado em python suporta arquivos no formato `CSV` apenas.
- O projeto suporta três nomenclaturas para os arquivos: NOME_ARQUIVO_{ANO}, NOME_ARQUIVO_{ANOMES}, NOME_ARQUIVO_{ANOMESDIA}. Ex. VENDAS_2025.

![](/docs/assets/demonstracao_arquitetura.gif)


## Free-tier GCP
- Este é um projeto capaz de ser executado e mantido por algum tempo na categoria free-tier do GCP. Atente-se ao limite de recursos que podem ser utilizados para cada Serviço.

- Storage: 5GB; 5000 operacoes A/mes; 50000 operacoes B/mes
- CloudRun: 2 milhões req/mes; 360,000 GB-seg de memória, 180,000 vCPU-seg de tempo computação
- BigQuery: 10GB armazenamento; 1TB queries/mes

>> Referência:  https://cloud.google.com/free/docs/free-cloud-features#storage

## Dashboard
![https://lookerstudio.google.com/reporting/af150ef4-18eb-4ce8-a9a8-204f51359ef1](/docs/assets/dashboard.png)


## Indicações de Melhorias
- Criar mais integrações de funções no cloud run para outros formatos de arquivos.
- A medida que os fluxos de dados crescerem utilizar uma ferramenta como o Apache Airflow para realizar a orquestração dos pipelines.
- Modelagem dos dados do DW com o objetivo de performance nas análises dos dados.
- Estruturação de um Lakehouse.


## Histórico de Atualizações

*0.0.1
    * Projeto Inicial


## Meta

Julio Zeferino - [@Linkedin](https://www.linkedin.com/in/julioszeferino/) - julioszeferino@gmail.com
[https://github.com/julioszeferino]