# Enterprise DW com BigQuery

> Este pipeline foi criado com o objetivo de entregar um fluxo de dados funcional no gpc com baixo custo e que, a depender da volumetria, pode se encaixar no free-tier da GCP por um bom tempo.

- O Fluxo de dados é orientado a eventos. Os dados são movimentados para o DW à medida que chegam ao bucket.
- O pipeline utiliza uma função no cloud functions para servir como "listener" e realizar a inserção dos dados no bigquery.
- Os dados de entrada são armazenados no `GCP Storage`
- Os dados são armazenados no `BigQuery`.
- Toda a execução do projeto é orquestrada pelo `GCP Cloud Functions`.
- Ao final, a análise dos dados é disponibilizada via `Looker`.

Stack de Tecnologias


Decisões Arquiteturais do Projeto


Como Executar o Projeto


Free-tier GCP


Dashboard

Referências


Histórico de Atualizações

Meta