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
