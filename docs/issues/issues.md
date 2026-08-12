# Issues - Databricks Lakehouse

Guia de organização para GitHub Issues + Projects (kanban) + Milestones.
Copie cada bloco diretamente na criação de uma issue no GitHub.

---

## 🏷️ Labels sugeridas (criar antes de tudo)

Vá em **Issues → Labels → New label** e crie:

| Label | Cor sugerida | Uso |
|---|---|---|
| `bronze` | 🟤 marrom (`#8B5E3C`) | Tarefas da camada Bronze |
| `silver` | ⚪ cinza (`#C0C0C0`) | Tarefas da camada Silver |
| `gold` | 🟡 amarelo (`#FFD700`) | Tarefas da camada Gold |
| `setup` | 🔵 azul (`#0E8A16`) | Configuração de ambiente/infra |
| `automation` | 🟣 roxo (`#5319E7`) | Jobs, orquestração, CI/CD |
| `docs` | 🟢 verde (`#0075CA`) | Documentação, README, dicionários |
| `bonus` | 🌸 rosa (`#D876E3`) | Sprints 6 e 7 (opcionais) |
| `bug` | 🔴 vermelho (`#D73A4A`) | Correções |

---

## 🎯 Milestones sugeridas

Crie em **Issues → Milestones → New milestone**, uma por sprint, com prazo de 1 semana cada:

1. `Sprint 1 - Setup + Bronze`
2. `Sprint 2 - Silver`
3. `Sprint 3 - Gold + Modelagem Dimensional`
4. `Sprint 4 - Automação + Governança`
5. `Sprint 5 - Time Travel + Dashboard + Documentação`
6. `Sprint 6 (Bônus) - Lakeflow Declarative Pipelines`
7. `Sprint 7 (Bônus) - CI com GitHub Actions`

---

## 📋 GitHub Projects (kanban)

Crie um Project (view: Board) com colunas:

`Backlog` → `Sprint atual` → `Em progresso` → `Em revisão` → `Concluído`

Vincule todas as issues abaixo ao Project ao criá-las (ou em lote depois, selecionando todas e usando "Add to project").

---

## Sprint 1 - Setup + Bronze

### #1 Criar repositório GitHub e estrutura de pastas
**Labels:** `setup`, `docs`
**Milestone:** Sprint 1 - Setup + Bronze

**Descrição:**
Criar o repositório `databricks-lakehouse` no GitHub com a estrutura de pastas inicial definida no README (`notebooks/`, `data/raw/`, `docs/`, `.gitignore`).

**Critério de aceite:**
- [ ] Repositório criado e público
- [ ] Estrutura de pastas commitada
- [ ] README.md inicial commitado
- [ ] `.gitignore` configurado (template Python)

---

### #2 Configurar Databricks Free Edition
**Labels:** `setup`
**Milestone:** Sprint 1 - Setup + Bronze

**Descrição:**
Criar conta no Databricks Free Edition e confirmar que o Unity Catalog está habilitado por padrão no workspace.

**Critério de aceite:**
- [ ] Workspace acessível
- [ ] Unity Catalog confirmado como habilitado

---

### #3 Conectar Git folder ao GitHub
**Labels:** `setup`
**Milestone:** Sprint 1 - Setup + Bronze

**Descrição:**
Gerar fine-grained PAT no GitHub (escopo mínimo: Contents read/write + Workflows read/write) e conectar o Databricks Git folder ao repositório.

**Critério de aceite:**
- [ ] Token gerado com escopo mínimo
- [ ] Git credential configurada em Settings → Linked accounts
- [ ] Git folder clonado com sucesso no Workspace

---

### #4 Criar catalog/schemas e volume
**Labels:** `setup`, `bronze`
**Milestone:** Sprint 1 - Setup + Bronze

**Descrição:**
Criar o catalog `olist_project` com os schemas `bronze`, `silver`, `gold`, e o volume pra armazenar os CSVs brutos.

**Critério de aceite:**
- [ ] `CREATE CATALOG olist_project` executado
- [ ] 3 schemas criados
- [ ] Volume `bronze.raw_files` criado

---

### #5 Baixar dataset Olist e subir para o Volume
**Labels:** `setup`, `bronze`
**Milestone:** Sprint 1 - Setup + Bronze

**Descrição:**
Baixar os 9 CSVs do dataset Olist no Kaggle e fazer upload para o Volume via UI do Catalog.

**Critério de aceite:**
- [ ] 9 arquivos CSV visíveis no volume

---

### #6 Notebook 00_setup.py
**Labels:** `setup`
**Milestone:** Sprint 1 - Setup + Bronze

**Descrição:**
Criar notebook inicial com validações de ambiente (catalog existe, volume acessível, listagem dos arquivos).

**Critério de aceite:**
- [ ] Notebook roda sem erro
- [ ] Lista os 9 arquivos do volume como confirmação

---

### #7 Notebook 01_bronze_ingestion.py
**Labels:** `bronze`
**Milestone:** Sprint 1 - Setup + Bronze

**Descrição:**
Ingerir os 9 CSVs como tabelas Delta na camada Bronze, sem nenhuma transformação.

**Critério de aceite:**
- [ ] 9 tabelas Delta visíveis em `olist_project.bronze`
- [ ] Contagem de linhas confere com os CSVs originais

---

### #8 Documentar dicionário de dados
**Labels:** `docs`
**Milestone:** Sprint 1 - Setup + Bronze

**Descrição:**
Criar `docs/data_dictionary.md` com a descrição de todas as 9 tabelas, colunas principais e relacionamentos.

**Critério de aceite:**
- [ ] Arquivo criado e linkado no README

---

## Sprint 2 - Silver

### #9 Notebook 02_silver_transform.py - limpeza de orders
**Labels:** `silver`
**Milestone:** Sprint 2 - Silver

**Descrição:**
Limpar a tabela `orders`: remover duplicatas por `order_id`, converter timestamps, filtrar nulos em colunas-chave.

**Critério de aceite:**
- [ ] Tabela `silver.orders` criada
- [ ] Zero duplicatas por `order_id`
- [ ] Colunas de data com tipo `timestamp`

---

### #10 Limpeza de customers, products, sellers
**Labels:** `silver`
**Milestone:** Sprint 2 - Silver

**Descrição:**
Aplicar o mesmo padrão de limpeza (dedup, tipagem, filtro de nulos) para as 3 tabelas.

**Critério de aceite:**
- [ ] 3 tabelas Silver criadas e validadas

---

### #11 Limpeza de order_items e order_payments
**Labels:** `silver`
**Milestone:** Sprint 2 - Silver

**Descrição:**
Aplicar limpeza nas tabelas de itens e pagamentos, garantindo consistência com `orders`.

**Critério de aceite:**
- [ ] 2 tabelas Silver criadas
- [ ] Chaves estrangeiras (`order_id`) validadas contra `silver.orders`

---

### #12 Simular carga incremental + MERGE INTO
**Labels:** `silver`
**Milestone:** Sprint 2 - Silver

**Descrição:**
Criar um subconjunto de dados simulando um novo "batch" e aplicar `MERGE INTO` na tabela `silver.orders` como upsert.

**Critério de aceite:**
- [ ] `MERGE INTO` executado com sucesso
- [ ] `DESCRIBE HISTORY` mostra a operação registrada
- [ ] Output documentado no README

---

### #13 Validação de qualidade
**Labels:** `silver`, `docs`
**Milestone:** Sprint 2 - Silver

**Descrição:**
Rodar queries de contagem de nulos e duplicatas antes/depois da limpeza, documentando os resultados.

**Critério de aceite:**
- [ ] Comparativo antes/depois documentado (tabela ou print)

---

## Sprint 3 - Gold + Modelagem Dimensional

### #14 Modelar star schema
**Labels:** `gold`, `docs`
**Milestone:** Sprint 3 - Gold + Modelagem Dimensional

**Descrição:**
Criar `docs/star_schema.md` com o desenho da tabela fato e das dimensões, e as chaves de relacionamento.

**Critério de aceite:**
- [ ] Diagrama (mesmo que em texto/ASCII) documentado

---

### #15 Notebook 03_gold_aggregation.py - fact_orders
**Labels:** `gold`
**Milestone:** Sprint 3 - Gold + Modelagem Dimensional

**Descrição:**
Criar a tabela fato `gold.fact_orders`, unindo orders e order_items.

**Critério de aceite:**
- [ ] `gold.fact_orders` criada e validada

---

### #16 dim_customer, dim_product, dim_seller
**Labels:** `gold`
**Milestone:** Sprint 3 - Gold + Modelagem Dimensional

**Descrição:**
Criar as 3 tabelas de dimensão a partir das tabelas Silver correspondentes.

**Critério de aceite:**
- [ ] 3 tabelas de dimensão criadas
- [ ] Chaves primárias sem duplicatas

---

### #17 Queries de métricas de negócio
**Labels:** `gold`
**Milestone:** Sprint 3 - Gold + Modelagem Dimensional

**Descrição:**
Escrever pelo menos 3 queries de negócio (vendas por estado/mês, ticket médio, ranking de categorias), incluindo uma com window function.

**Critério de aceite:**
- [ ] 3+ queries documentadas com resultado
- [ ] Pelo menos 1 usa window function

---

## Sprint 4 - Automação + Governança

### #18 Criar Job encadeando Bronze → Silver → Gold
**Labels:** `automation`
**Milestone:** Sprint 4 - Automação + Governança

**Descrição:**
Criar um Databricks Job (Workflow) com 3 tasks sequenciais, cada uma rodando um notebook de camada.

**Critério de aceite:**
- [ ] Job criado com dependências corretas
- [ ] Execução manual bem-sucedida

---

### #19 Agendar o Job
**Labels:** `automation`
**Milestone:** Sprint 4 - Automação + Governança

**Descrição:**
Configurar um trigger de schedule (cron) para o Job criado na issue #18.

**Critério de aceite:**
- [ ] Schedule configurado
- [ ] Ao menos 1 execução automática registrada no histórico

---

### #20 Rodar OPTIMIZE nas tabelas Silver/Gold
**Labels:** `automation`, `silver`, `gold`
**Milestone:** Sprint 4 - Automação + Governança

**Descrição:**
Executar `OPTIMIZE` nas principais tabelas e documentar o que o comando faz.

**Critério de aceite:**
- [ ] `OPTIMIZE` executado em pelo menos 2 tabelas
- [ ] Explicação documentada no README

---

### #21 Rodar VACUUM e documentar retenção
**Labels:** `automation`
**Milestone:** Sprint 4 - Automação + Governança

**Descrição:**
Executar `VACUUM` com a retenção padrão (7 dias) e documentar o comportamento.

**Critério de aceite:**
- [ ] `VACUUM` executado
- [ ] Explicação da retenção documentada

---

### #22 Capturar Lineage Graph no Unity Catalog
**Labels:** `automation`, `docs`
**Milestone:** Sprint 4 - Automação + Governança

**Descrição:**
Após algumas execuções do Job, capturar print do grafo de lineage mostrando o fluxo bronze → silver → gold.

**Critério de aceite:**
- [ ] Print salvo em `screenshots/`
- [ ] Referenciado no README

---

## Sprint 5 - Time Travel + Dashboard + Documentação final

### #23 Notebook 04_time_travel_demo.py
**Labels:** `docs`
**Milestone:** Sprint 5 - Time Travel + Dashboard + Documentação

**Descrição:**
Simular um incidente real (ex: DELETE indevido) e recuperar via `RESTORE TABLE ... VERSION AS OF`.

**Critério de aceite:**
- [ ] Incidente simulado e documentado (horário, causa, comando de recuperação)

---

### #24 Criar dashboard no Databricks SQL
**Labels:** `gold`
**Milestone:** Sprint 5 - Time Travel + Dashboard + Documentação

**Descrição:**
Criar um dashboard com 2-3 gráficos a partir das queries de negócio da camada Gold.

**Critério de aceite:**
- [ ] Dashboard publicado
- [ ] Print salvo em `screenshots/`

---

### #25 Finalizar README.md completo
**Labels:** `docs`
**Milestone:** Sprint 5 - Time Travel + Dashboard + Documentação

**Descrição:**
Revisar e completar todas as seções pendentes do README (registro do incidente, badges, etc).

**Critério de aceite:**
- [ ] Todos os placeholders preenchidos

---

### #26 Revisão geral do repositório
**Labels:** `docs`
**Milestone:** Sprint 5 - Time Travel + Dashboard + Documentação

**Descrição:**
Limpar notebooks (remover células de teste/debug), revisar nomes de arquivos e organização geral.

**Critério de aceite:**
- [ ] Nenhuma célula de debug/teste solta nos notebooks finais

---

### #27 Publicar no LinkedIn / portfólio
**Labels:** `docs`
**Milestone:** Sprint 5 - Time Travel + Dashboard + Documentação

**Descrição:**
Compartilhar o projeto publicamente como marco de conclusão.

**Critério de aceite:**
- [ ] Post publicado com link do repositório

---

## Sprint 6 (Bônus) - Lakeflow Declarative Pipelines

### #28 Estudar tutorial oficial de Lakeflow Declarative Pipelines
**Labels:** `bonus`, `docs`
**Milestone:** Sprint 6 (Bônus) - Lakeflow Declarative Pipelines

**Descrição:**
Ler a documentação oficial e entender a diferença de sintaxe/paradigma em relação ao pipeline imperativo já construído.

**Critério de aceite:**
- [ ] Notas de estudo registradas (pode ser no próprio PR ou em `docs/`)

---

### #29 Criar pipeline declarativo recriando orders_silver
**Labels:** `bonus`, `silver`
**Milestone:** Sprint 6 (Bônus) - Lakeflow Declarative Pipelines

**Descrição:**
Usar `@dp.materialized_view` para recriar a lógica de limpeza de `orders_silver` em `notebooks/bonus_ldp_pipeline/`.

**Critério de aceite:**
- [ ] Pipeline declarativo criado e executando com sucesso

---

### #30 Adicionar expectativas de qualidade
**Labels:** `bonus`
**Milestone:** Sprint 6 (Bônus) - Lakeflow Declarative Pipelines

**Descrição:**
Usar `@dp.expect_or_drop` para validar qualidade de dados diretamente no pipeline declarativo.

**Critério de aceite:**
- [ ] Pelo menos 1 expectativa configurada e testada

---

### #31 Comparar pipeline declarativo vs imperativo
**Labels:** `bonus`, `docs`
**Milestone:** Sprint 6 (Bônus) - Lakeflow Declarative Pipelines

**Descrição:**
Rodar as duas versões e comparar tempo de execução, legibilidade do código e facilidade de monitoramento.

**Critério de aceite:**
- [ ] Comparação documentada (tabela ou texto)

---

### #32 Escrever seção "Imperative vs Declarative" no README
**Labels:** `bonus`, `docs`
**Milestone:** Sprint 6 (Bônus) - Lakeflow Declarative Pipelines

**Descrição:**
Consolidar os aprendizados da sprint em uma seção clara no README.

**Critério de aceite:**
- [ ] Seção publicada no README

---

## Sprint 7 (Bônus) - CI com GitHub Actions

### #33 Adicionar requirements-dev.txt com Ruff
**Labels:** `bonus`, `automation`
**Milestone:** Sprint 7 (Bônus) - CI com GitHub Actions

**Descrição:**
Criar `requirements-dev.txt` fixando a versão do Ruff (substitui flake8 + black + isort num único binário).

**Critério de aceite:**
- [ ] Arquivo criado na raiz do repositório

---

### #34 Criar pyproject.toml com config do Ruff compatível com notebooks Databricks
**Labels:** `bonus`, `automation`
**Milestone:** Sprint 7 (Bônus) - CI com GitHub Actions

**Descrição:**
Configurar `line-length`, `exclude` e `per-file-ignores` compatíveis com o formato de notebook Databricks (`.py` com comentário mágico `# Databricks notebook source` antes dos imports).

**Critério de aceite:**
- [ ] Seção `[tool.ruff]` criada em `pyproject.toml` e testada localmente (`ruff check .` e `ruff format --check .`)

---

### #35 Criar workflow .github/workflows/lint.yml
**Labels:** `bonus`, `automation`
**Milestone:** Sprint 7 (Bônus) - CI com GitHub Actions

**Descrição:**
Criar o GitHub Action que roda `ruff check` e `ruff format --check` em `notebooks/` a cada push/PR na `main`.

**Critério de aceite:**
- [ ] Workflow criado
- [ ] Action executa com sucesso após primeiro push

---

### #36 Testar o Action com push proposital com erro de lint
**Labels:** `bonus`, `automation`
**Milestone:** Sprint 7 (Bônus) - CI com GitHub Actions

**Descrição:**
Fazer um commit com erro de lint proposital, abrir PR, confirmar que o Action falha; corrigir e confirmar que passa.

**Critério de aceite:**
- [ ] Link do PR que falhou documentado
- [ ] Link do PR que corrigiu documentado

---

### #37 Adicionar badge de status do CI no README
**Labels:** `bonus`, `docs`
**Milestone:** Sprint 7 (Bônus) - CI com GitHub Actions

**Descrição:**
Adicionar o badge do workflow no topo do README, substituindo o placeholder `<usuario>`.

**Critério de aceite:**
- [ ] Badge visível e funcional no README renderizado no GitHub
