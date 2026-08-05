Sprint 6 (Bônus, opcional) - Lakeflow Declarative Pipelines
---

Objetivo: recriar a camada Silver de orders usando o paradigma declarativo (o antigo Delta Live Tables) e comparar as duas abordagens.

[ ] #28 Estudar tutorial oficial de Lakeflow Declarative Pipelines

[ ] #29 Criar pipeline declarativo recriando orders_silver com @dp.materialized_view

[ ] #30 Adicionar expectativas de qualidade com @dp.expect_or_drop

[ ] #31 Rodar o pipeline e comparar com a versão imperativa

[ ] #32 Escrever seção "Imperative vs Declarative" comparando as duas abordagens

Critério de "pronto": pipeline declarativo rodando com sucesso, seção comparativa no README (menos código e qualidade de dados embutida no declarativo, vs. mais controle fino e valor didático no imperativo).
