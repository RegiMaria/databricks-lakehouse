<p align="center">
  <img src="https://github.com/user-attachments/assets/2aba3fcf-da06-4f5c-99c3-83ff2fa455a1"
       alt="Databricks Lakehouse"
       width="200">
</p>

<h1 align="center">databricks-lakehouse</h1>

<p align="center">
  <a href="LINK_AWS_BADGE">
    <img src="https://github.com/user-attachments/assets/c0f48f2b-44f4-4023-800f-f4d58eb896ca"
         width="180"
         alt="AWS Databricks Platform Architect">
  </a>

  <a href="LINK_AZURE_BADGE">
    <img src="https://github.com/user-attachments/assets/7f72b57b-43b9-4f44-a9da-91767d967835"
         width="180"
         alt="Azure Databricks Platform Architect">
  </a>

  <a href="LINK_GCP_BADGE">
    <img src="https://github.com/user-attachments/assets/f853ce8c-cae2-4dc5-a793-eaf85965cdd1"
         width="180"
         alt="GCP Databricks Platform Architect">
  </a>
</p>

<p align="center">
  <b>Databricks Platform Architect</b> • AWS • Azure • Google Cloud
</p>

<p align="center">
  <a href="https://credentials.databricks.com/profile/regileneamodasilva957596/wallet" target="_blank">
    ⭐ View all my Databricks Credentials
  </a>
</p>

## Databricks-Lakehouse

Pipeline de dados end-to-end em arquitetura medalhão (Bronze → Silver → Gold) construído no [Databricks Free Edition](https://docs.databricks.com/aws/en/getting-started/free-edition), usando o dataset público [Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

Projeto criado com fins de aprendizado, cobrindo os fundamentos de engenharia de dados em um ambiente lakehouse moderno: 
Delta Lake, PySpark, SQL, Unity Catalog, orquestração de jobs, lineage e Lakeflow Declarative Pipelines.

## Arquitetura

Este projeto segue a [Medallion Architecture](https://www.databricks.com/blog/what-is-medallion-architecture), o padrão recomendado pela própria Databricks para organizar dados em camadas de qualidade progressiva:

| Camada | Descrição |
|:-------:|-----------|
| 🥉 **Bronze** | Dados brutos, ingeridos como estão, sem transformações. |
| 🥈 **Silver** | Dados limpos, tipados, deduplicados e atualizados com **`MERGE INTO`** (upserts). |
| 🥇 **Gold** | Modelo dimensional (**Star Schema**), pronto para BI, dashboards e análises. |

<p align="center">
  <img src="https://www.databricks.com/sites/default/files/inline-images/building-data-pipelines-with-delta-lake-120823.png"
       alt="Medallion Architecture"
       width="700">
  <br>
  <sub>
    Fonte:
    <a href="https://www.databricks.com/blog/what-is-medallion-architecture">
      Databricks – What is Medallion Architecture?
    </a>
  </sub>
</p>

## Tecnologias

- Databricks Free Edition
- Apache Spark / PySpark
- Delta Lake (ACID, Time Travel, MERGE INTO, OPTIMIZE, VACUUM)
- Spark SQL / Databricks SQL
- Unity Catalog (catalog → schema → tabela/volume, lineage)
- Databricks Jobs (Lakeflow Jobs) - orquestração automatizada
- Git & GitHub (Databricks Git folders)
- GitHub Actions (CI - lint automatizado)
- (Bônus / opcional) Lakeflow Declarative Pipelines

## Dataset

Brazilian [E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) - dados reais e anonimizados de ~100 mil pedidos feitos na loja Olist entre 2016-2018.

| Tabela | Chave Primária | Descrição |
|---------|----------------|-----------|
| `olist_customers_dataset` | `customer_id` | Dados dos clientes (cidade e estado). |
| `olist_orders_dataset` | `order_id` | Pedidos, incluindo status e timestamps. |
| `olist_order_items_dataset` | `order_id` + `order_item_id` | Itens de cada pedido, com preço e valor do frete. |
| `olist_order_payments_dataset` | `order_id` | Informações de pagamento, parcelas e valor pago. |
| `olist_order_reviews_dataset` | `review_id` | Avaliações dos pedidos realizadas pelos clientes. |
| `olist_products_dataset` | `product_id` | Dados dos produtos, incluindo categoria, dimensões e peso. |
| `olist_sellers_dataset` | `seller_id` | Informações dos vendedores, cidade e estado. |
| `olist_geolocation_dataset` | `geolocation_zip_code_prefix` | Coordenadas geográficas (latitude e longitude) por CEP. |
| `product_category_name_translation` | `product_category_name` | Tradução das categorias de produtos do português para o inglês. |

Relacionamento central: orders → order_items → products/sellers, e orders → customers, payments, reviews.

Detalhamento completo em [docs/data_dictionary.md](https://github.com/RegiMaria/databricks-lakehouse/blob/main/docs/tutorials/04_data_dictionary.md).

## Estrutura do repositório
```
olist-lakehouse/
├── .github/
│   └── workflows/
│       └── lint.yml                ← Sprint 7, CI com flake8
├── notebooks/
│   ├── 00_setup.py
│   ├── 01_bronze_ingestion.py
│   ├── 02_silver_transform.py
│   ├── 03_gold_aggregation.py
│   ├── 04_time_travel_demo.py
│   └── bonus_ldp_pipeline/        ← Sprint 6 (bônus), Lakeflow Declarative Pipelines
├── data/raw/                       (amostra pequena, ou apenas instruções de download)
├── docs/
│   ├── data_dictionary.md
│   └── star_schema.md
│   └── how to do
├── screenshots/                    (lineage graph, job runs, dashboard)
├── requirements-dev.txt            ← Sprint 7
├── .flake8                         ← Sprint 7
├── .gitignore
└── README.md
```

## Pré-requisitos

1. Contas e ferramentas

- Conta no Databricks Free Edition
- Conta no GitHub
- Git instalado localmente (ou uso via Databricks Git folders)
- Conta no Kaggle (para baixar o dataset Olist)

2. Conceitos recomendados antes de começar
- Git/GitHub: clone, branch, commit, push, pull, merge, pull request
- ETL/ELT e Medallion Architecture
- Modelagem dimensional (star schema: fato + dimensões)
- SQL básico: joins, group by, window functions
- Python/PySpark básico: DataFrame API (select, filter, groupBy, join)
- Delta Lake: ACID transactions, MERGE INTO, time travel, OPTIMIZE/VACUUM
- Unity Catalog: conceito de catalog → schema → tabela/volume

## Setup 

`git clone https://github.com/<usuario>/olist-lakehouse.git`
`cd olist-lakehouse`

No Databricks: Workspace → Repos → Add Repo, conectar ao GitHub (permite commitar/pushar direto do notebook).

Criação do catalog/schemas (Unity Catalog):
CREATE CATALOG IF NOT EXISTS olist_project;
CREATE SCHEMA IF NOT EXISTS olist_project.bronze;
CREATE SCHEMA IF NOT EXISTS olist_project.silver;
CREATE SCHEMA IF NOT EXISTS olist_project.gold;
CREATE VOLUME IF NOT EXISTS olist_project.bronze.raw_files;

Upload dos CSVs do Kaggle para o Volume via UI: Catalog → volume → Upload.

## Plano de sprints

Projeto dividido em 5 sprints de 1 semana + 1 sprint bônus, organizadas como Issues/Milestones no GitHub.


Sprint 1 - Setup + Bronze (Semana 1)
---

Objetivo: ambiente funcionando, dados brutos ingeridos como Delta Table sem transformação.

[ ] #1 Criar repositório GitHub e estrutura de pastas

[ ] #2 Configurar Databricks Free Edition (workspace, Unity Catalog)

[ ] #3 Conectar Git folder ao GitHub

[ ] #4 Criar catalog/schemas (bronze, silver, gold) e volume

[ ] #5 Baixar dataset Olist e subir para o Volume

[ ] #6 Notebook 00_setup.py

[ ] #7 Notebook 01_bronze_ingestion.py - ingestão dos 9 CSVs como Delta

[ ] #8 Documentar dicionário de dados ([docs/data_dictionary.md](https://github.com/RegiMaria/databricks-lakehouse/blob/main/docs/tutorials/04_data_dictionary.md))

Critério de "pronto": 9 tabelas Delta visíveis em `olist_project.bronze`, README com seção de setup preenchida.


Sprint 2 - Silver (Semana 2)
---

Objetivo: dados limpos, tipados, deduplicados, com upsert via MERGE INTO.

[ ] #9 Notebook 02_silver_transform.py — limpeza de orders

[ ] #10 Limpeza de customers, products, sellers

[ ] #11 Limpeza de order_items e order_payments

[ ] #12 Simular carga incremental (novo batch) + MERGE INTO

[ ] #13 Validação de qualidade: contagem de nulos, duplicatas antes/depois

Critério de "pronto": todas as tabelas Silver populadas, zero duplicatas por chave primária, `MERGE INTO` documentado com output do `DESCRIBE HISTORY`.


Sprint 3 - Gold + Modelagem Dimensional (Semana 3)
---

Objetivo: star schema pronto para análise.

[ ] #14 Modelar star schema em docs/star_schema.md (fato + dimensões)

[ ] #15 Notebook 03_gold_aggregation.py — fact_orders

[ ] #16 dim_customer, dim_product, dim_seller

[ ] #17 Queries de métricas de negócio (vendas por estado/mês, ticket médio)

Critério de "pronto": diagrama do star schema documentado, 3+ queries de negócio com resultado.

Sprint 4 - Automação + Governança (Semana 4)
---

Objetivo: pipeline orquestrado como Job de verdade, com manutenção e lineage.

[ ] #18 Criar Job (Workflow) encadeando os notebooks Bronze → Silver → Gold

[ ] #19 Agendar o Job (schedule/cron)

[ ] #20 Rodar OPTIMIZE nas tabelas Silver/Gold

[ ] #21 Rodar VACUUM e documentar retenção

[ ] #22 Explorar e capturar prints do Lineage Graph no Unity Catalog


- Job: Workspace → Jobs & Pipelines → Create Job → adicionar 3 tasks (Bronze, Silver, Gold) com dependência sequencial (Silver depende de Bronze, Gold depende de Silver).
```
OPTIMIZE olist_project.silver.orders;
VACUUM olist_project.silver.orders RETAIN 168 HOURS; -- padrão 7 dias
```
- Lineage: depois de rodar o Job algumas vezes, ir em Catalog → tabela → aba Lineage e capturar o grafo bronze.orders → silver.orders → gold.fact_orders.
  
Critério de "pronto": Job rodando com sucesso (histórico de runs visível), lineage graph capturado, OPTIMIZE/VACUUM documentados.

Sprint 5 - Time Travel + Dashboard + Documentação final (Semana 5)
---

[ ] #23 Notebook 04_time_travel_demo.py — simular erro e recuperar

[ ] #24 Criar dashboard no Databricks SQL (2-3 gráficos)

[ ] #25 Finalizar README.md completo

[ ] #26 Revisão geral do repositório e limpeza de notebooks

[ ] #27 Publicar no LinkedIn / portfólio

Critério de "pronto": incidente documentado com horário e comando de recuperação, dashboard publicado, README revisado.

Sprint 6 (Bônus, opcional) - Lakeflow Declarative Pipelines
---

Objetivo: recriar a camada Silver de orders usando o paradigma declarativo (o antigo Delta Live Tables) e comparar as duas abordagens.

[ ] #28 Estudar tutorial oficial de Lakeflow Declarative Pipelines

[ ] #29 Criar pipeline declarativo recriando orders_silver com @dp.materialized_view

[ ] #30 Adicionar expectativas de qualidade com @dp.expect_or_drop

[ ] #31 Rodar o pipeline e comparar com a versão imperativa

[ ] #32 Escrever seção "Imperative vs Declarative" comparando as duas abordagens

Critério de "pronto": pipeline declarativo rodando com sucesso, seção comparativa no README (menos código e qualidade de dados embutida no declarativo, vs. mais controle fino e valor didático no imperativo).

Sprint 7 (Bônus, opcional) - CI enxuto com GitHub Actions
---

Objetivo: a cada push/PR no GitHub, rodar automaticamente uma checagem de qualidade de código (lint) nos notebooks Python, sem fazer deploy no Databricks. Mostra domínio do conceito de CI (Integração Contínua) isoladamente do CD (Deploy).

[ ] #33 Adicionar requirements-dev.txt com flake8

[ ] #34 Criar .flake8 com regras compatíveis com notebooks Databricks

[ ] #35 Criar workflow .github/workflows/lint.yml

[ ] #36 Testar o Action com um push proposital com erro de lint

[ ] #37 Adicionar badge de status do CI no README

Critério de "pronto": Action rodando automaticamente em todo push/PR, com pelo menos um ciclo de falha→correção documentado (print ou link do PR), badge visível no topo do README.

##  Documentação oficial de referência

| 📚 Tópico | 🔗 Documentação Oficial |
|-----------|-------------------------|
| Git folders (Databricks) | https://docs.databricks.com/aws/en/repos |
| Medallion Architecture | https://docs.databricks.com/gcp/en/lakehouse/medallion |
| Star Schema | https://www.databricks.com/blog/what-is-star-schema |
| PySpark Basics | https://docs.databricks.com/aws/en/pyspark/basics |
| Window Functions | https://docs.databricks.com/gcp/en/sql/language-manual/sql-ref-window-functions |
| Delta Lake - Tutorial Completo | https://docs.databricks.com/aws/en/delta/tutorial |
| Delta Lake - Table History (Time Travel) | https://docs.databricks.com/aws/en/tables/history |
| Delta Lake - Cheat Sheet (PDF) | https://www.databricks.com/sites/default/files/2022-08/delta-lake-cheat-sheet.pdf |
| Unity Catalog | https://docs.databricks.com/aws/en/data-governance/unity-catalog |
| Unity Catalog - Catalogs | https://docs.databricks.com/aws/en/catalogs |
| Unity Catalog - Volumes | https://docs.databricks.com/aws/en/volumes |
| Lakeflow Declarative Pipelines - Tutorial | https://docs.databricks.com/aws/en/getting-started/data-pipeline-get-started |
| Lakeflow Declarative Pipelines - Sintaxe Python | https://docs.databricks.com/aws/en/ldp/developer/python-dev |
| O que aconteceu com o DLT? | https://docs.databricks.com/aws/en/ldp/concepts/where-is-dlt |
| CI/CD no Databricks (Asset Bundles) | https://docs.databricks.com/aws/en/dev-tools/ci-cd |
