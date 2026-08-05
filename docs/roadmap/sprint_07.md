Sprint 7 (Bônus, opcional) - CI enxuto com GitHub Actions
---

Objetivo: a cada push/PR no GitHub, rodar automaticamente uma checagem de qualidade de código (lint) nos notebooks Python, sem fazer deploy no Databricks. Mostra domínio do conceito de CI (Integração Contínua) isoladamente do CD (Deploy).

[ ] #33 Adicionar requirements-dev.txt com flake8

[ ] #34 Criar .flake8 com regras compatíveis com notebooks Databricks

[ ] #35 Criar workflow .github/workflows/lint.yml

[ ] #36 Testar o Action com um push proposital com erro de lint

[ ] #37 Adicionar badge de status do CI no README

Critério de "pronto": Action rodando automaticamente em todo push/PR, com pelo menos um ciclo de falha→correção documentado (print ou link do PR), badge visível no topo do README.
