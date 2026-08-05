Sprint 2 - Silver (Semana 2)
---

Objetivo: dados limpos, tipados, deduplicados, com upsert via MERGE INTO.

[ ] #9 Notebook 02_silver_transform.py — limpeza de orders

[ ] #10 Limpeza de customers, products, sellers

[ ] #11 Limpeza de order_items e order_payments

[ ] #12 Simular carga incremental (novo batch) + MERGE INTO

[ ] #13 Validação de qualidade: contagem de nulos, duplicatas antes/depois

Critério de "pronto": todas as tabelas Silver populadas, zero duplicatas por chave primária, `MERGE INTO` documentado com output do `DESCRIBE HISTORY`.
