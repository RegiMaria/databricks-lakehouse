#!/usr/bin/env bash
set -e

# ============================================================
# Setup automático de Labels, Milestones e Issues
# Projeto: databricks-lakehouse
# ============================================================
# Uso:
#   1. Ajuste a variável REPO abaixo
#   2. chmod +x setup-github-issues.sh
#   3. ./setup-github-issues.sh
# ============================================================

REPO="RegiMaria/databricks-lakehouse"   # <-- ajuste se o nome do repo for diferente

echo "Repositório alvo: $REPO"
echo "Confirmando autenticação..."
gh auth status

# ------------------------------------------------------------
# 1. LABELS
# ------------------------------------------------------------
echo ""
echo "==> Criando labels..."

create_label () {
  local name="$1"
  local color="$2"
  local desc="$3"
  gh label create "$name" --repo "$REPO" --color "$color" --description "$desc" --force
}

create_label "bronze"     "8B5E3C" "Tarefas da camada Bronze"
create_label "silver"     "C0C0C0" "Tarefas da camada Silver"
create_label "gold"       "FFD700" "Tarefas da camada Gold"
create_label "setup"      "0E8A16" "Configuração de ambiente/infra"
create_label "automation" "5319E7" "Jobs, orquestração, CI/CD"
create_label "docs"       "0075CA" "Documentação, README, dicionários"
create_label "bonus"      "D876E3" "Sprints 6 e 7 (opcionais)"
create_label "bug"        "D73A4A" "Correções"

# ------------------------------------------------------------
# 2. MILESTONES
# ------------------------------------------------------------
echo ""
echo "==> Criando milestones..."

create_milestone () {
  local title="$1"
  gh api "repos/$REPO/milestones" -f title="$title" --silent || echo "   (milestone '$title' já existe, ok)"
}

create_milestone "Sprint 1 — Setup + Bronze"
create_milestone "Sprint 2 — Silver"
create_milestone "Sprint 3 — Gold + Modelagem Dimensional"
create_milestone "Sprint 4 — Automação + Governança"
create_milestone "Sprint 5 — Time Travel + Dashboard + Documentação"
create_milestone "Sprint 6 (Bônus) — Lakeflow Declarative Pipelines"
create_milestone "Sprint 7 (Bônus) — CI com GitHub Actions"

# ------------------------------------------------------------
# 3. ISSUES
# ------------------------------------------------------------
echo ""
echo "==> Criando issues..."

create_issue () {
  local title="$1"
  local body="$2"
  local labels="$3"
  local milestone="$4"
  gh issue create --repo "$REPO" \
    --title "$title" \
    --body "$body" \
    --label "$labels" \
    --milestone "$milestone"
}

# ---------- Sprint 1 — Setup + Bronze ----------

create_issue "Criar repositório GitHub e estrutura de pastas" \
"Criar o repositório \`databricks-lakehouse\` no GitHub com a estrutura de pastas inicial definida no README (notebooks/, data/raw/, docs/, .gitignore).

**Critério de aceite:**
- [ ] Repositório criado e público
- [ ] Estrutura de pastas commitada
- [ ] README.md inicial commitado
- [ ] .gitignore configurado (template Python)" \
"setup,docs" "Sprint 1 — Setup + Bronze"

create_issue "Configurar Databricks Free Edition" \
"Criar conta no Databricks Free Edition e confirmar que o Unity Catalog está habilitado por padrão no workspace.

**Critério de aceite:**
- [ ] Workspace acessível
- [ ] Unity Catalog confirmado como habilitado" \
"setup" "Sprint 1 — Setup + Bronze"

create_issue "Conectar Git folder ao GitHub" \
"Gerar fine-grained PAT no GitHub (escopo mínimo: Contents read/write + Workflows read/write) e conectar o Databricks Git folder ao repositório.

**Critério de aceite:**
- [ ] Token gerado com escopo mínimo
- [ ] Git credential configurada em Settings → Linked accounts
- [ ] Git folder clonado com sucesso no Workspace" \
"setup" "Sprint 1 — Setup + Bronze"

create_issue "Criar catalog/schemas e volume" \
"Criar o catalog olist_project com os schemas bronze, silver, gold, e o volume pra armazenar os CSVs brutos.

**Critério de aceite:**
- [ ] CREATE CATALOG olist_project executado
- [ ] 3 schemas criados
- [ ] Volume bronze.raw_files criado" \
"setup,bronze" "Sprint 1 — Setup + Bronze"

create_issue "Baixar dataset Olist e subir para o Volume" \
"Baixar os 9 CSVs do dataset Olist no Kaggle e fazer upload para o Volume via UI do Catalog.

**Critério de aceite:**
- [ ] 9 arquivos CSV visíveis no volume" \
"setup,bronze" "Sprint 1 — Setup + Bronze"

create_issue "Notebook 00_setup.py" \
"Criar notebook inicial com validações de ambiente (catalog existe, volume acessível, listagem dos arquivos).

**Critério de aceite:**
- [ ] Notebook roda sem erro
- [ ] Lista os 9 arquivos do volume como confirmação" \
"setup" "Sprint 1 — Setup + Bronze"

create_issue "Notebook 01_bronze_ingestion.py" \
"Ingerir os 9 CSVs como tabelas Delta na camada Bronze, sem nenhuma transformação.

**Critério de aceite:**
- [ ] 9 tabelas Delta visíveis em olist_project.bronze
- [ ] Contagem de linhas confere com os CSVs originais" \
"bronze" "Sprint 1 — Setup + Bronze"

create_issue "Documentar dicionário de dados" \
"Criar docs/data_dictionary.md com a descrição de todas as 9 tabelas, colunas principais e relacionamentos.

**Critério de aceite:**
- [ ] Arquivo criado e linkado no README" \
"docs" "Sprint 1 — Setup + Bronze"

# ---------- Sprint 2 — Silver ----------

create_issue "Notebook 02_silver_transform.py — limpeza de orders" \
"Limpar a tabela orders: remover duplicatas por order_id, converter timestamps, filtrar nulos em colunas-chave.

**Critério de aceite:**
- [ ] Tabela silver.orders criada
- [ ] Zero duplicatas por order_id
- [ ] Colunas de data com tipo timestamp" \
"silver" "Sprint 2 — Silver"

create_issue "Limpeza de customers, products, sellers" \
"Aplicar o mesmo padrão de limpeza (dedup, tipagem, filtro de nulos) para as 3 tabelas.

**Critério de aceite:**
- [ ] 3 tabelas Silver criadas e validadas" \
"silver" "Sprint 2 — Silver"

create_issue "Limpeza de order_items e order_payments" \
"Aplicar limpeza nas tabelas de itens e pagamentos, garantindo consistência com orders.

**Critério de aceite:**
- [ ] 2 tabelas Silver criadas
- [ ] Chaves estrangeiras (order_id) validadas contra silver.orders" \
"silver" "Sprint 2 — Silver"

create_issue "Simular carga incremental + MERGE INTO" \
"Criar um subconjunto de dados simulando um novo batch e aplicar MERGE INTO na tabela silver.orders como upsert.

**Critério de aceite:**
- [ ] MERGE INTO executado com sucesso
- [ ] DESCRIBE HISTORY mostra a operação registrada
- [ ] Output documentado no README" \
"silver" "Sprint 2 — Silver"

create_issue "Validação de qualidade" \
"Rodar queries de contagem de nulos e duplicatas antes/depois da limpeza, documentando os resultados.

**Critério de aceite:**
- [ ] Comparativo antes/depois documentado (tabela ou print)" \
"silver,docs" "Sprint 2 — Silver"

# ---------- Sprint 3 — Gold + Modelagem Dimensional ----------

create_issue "Modelar star schema" \
"Criar docs/star_schema.md com o desenho da tabela fato e das dimensões, e as chaves de relacionamento.

**Critério de aceite:**
- [ ] Diagrama (mesmo que em texto/ASCII) documentado" \
"gold,docs" "Sprint 3 — Gold + Modelagem Dimensional"

create_issue "Notebook 03_gold_aggregation.py — fact_orders" \
"Criar a tabela fato gold.fact_orders, unindo orders e order_items.

**Critério de aceite:**
- [ ] gold.fact_orders criada e validada" \
"gold" "Sprint 3 — Gold + Modelagem Dimensional"

create_issue "dim_customer, dim_product, dim_seller" \
"Criar as 3 tabelas de dimensão a partir das tabelas Silver correspondentes.

**Critério de aceite:**
- [ ] 3 tabelas de dimensão criadas
- [ ] Chaves primárias sem duplicatas" \
"gold" "Sprint 3 — Gold + Modelagem Dimensional"

create_issue "Queries de métricas de negócio" \
"Escrever pelo menos 3 queries de negócio (vendas por estado/mês, ticket médio, ranking de categorias), incluindo uma com window function.

**Critério de aceite:**
- [ ] 3+ queries documentadas com resultado
- [ ] Pelo menos 1 usa window function" \
"gold" "Sprint 3 — Gold + Modelagem Dimensional"

# ---------- Sprint 4 — Automação + Governança ----------

create_issue "Criar Job encadeando Bronze → Silver → Gold" \
"Criar um Databricks Job (Workflow) com 3 tasks sequenciais, cada uma rodando um notebook de camada.

**Critério de aceite:**
- [ ] Job criado com dependências corretas
- [ ] Execução manual bem-sucedida" \
"automation" "Sprint 4 — Automação + Governança"

create_issue "Agendar o Job" \
"Configurar um trigger de schedule (cron) para o Job criado na issue anterior.

**Critério de aceite:**
- [ ] Schedule configurado
- [ ] Ao menos 1 execução automática registrada no histórico" \
"automation" "Sprint 4 — Automação + Governança"

create_issue "Rodar OPTIMIZE nas tabelas Silver/Gold" \
"Executar OPTIMIZE nas principais tabelas e documentar o que o comando faz.

**Critério de aceite:**
- [ ] OPTIMIZE executado em pelo menos 2 tabelas
- [ ] Explicação documentada no README" \
"automation,silver,gold" "Sprint 4 — Automação + Governança"

create_issue "Rodar VACUUM e documentar retenção" \
"Executar VACUUM com a retenção padrão (7 dias) e documentar o comportamento.

**Critério de aceite:**
- [ ] VACUUM executado
- [ ] Explicação da retenção documentada" \
"automation" "Sprint 4 — Automação + Governança"

create_issue "Capturar Lineage Graph no Unity Catalog" \
"Após algumas execuções do Job, capturar print do grafo de lineage mostrando o fluxo bronze → silver → gold.

**Critério de aceite:**
- [ ] Print salvo em screenshots/
- [ ] Referenciado no README" \
"automation,docs" "Sprint 4 — Automação + Governança"

# ---------- Sprint 5 — Time Travel + Dashboard + Documentação ----------

create_issue "Notebook 04_time_travel_demo.py" \
"Simular um incidente real (ex: DELETE indevido) e recuperar via RESTORE TABLE ... VERSION AS OF.

**Critério de aceite:**
- [ ] Incidente simulado e documentado (horário, causa, comando de recuperação)" \
"docs" "Sprint 5 — Time Travel + Dashboard + Documentação"

create_issue "Criar dashboard no Databricks SQL" \
"Criar um dashboard com 2-3 gráficos a partir das queries de negócio da camada Gold.

**Critério de aceite:**
- [ ] Dashboard publicado
- [ ] Print salvo em screenshots/" \
"gold" "Sprint 5 — Time Travel + Dashboard + Documentação"

create_issue "Finalizar README.md completo" \
"Revisar e completar todas as seções pendentes do README (registro do incidente, badges, etc).

**Critério de aceite:**
- [ ] Todos os placeholders preenchidos" \
"docs" "Sprint 5 — Time Travel + Dashboard + Documentação"

create_issue "Revisão geral do repositório" \
"Limpar notebooks (remover células de teste/debug), revisar nomes de arquivos e organização geral.

**Critério de aceite:**
- [ ] Nenhuma célula de debug/teste solta nos notebooks finais" \
"docs" "Sprint 5 — Time Travel + Dashboard + Documentação"

create_issue "Publicar no LinkedIn / portfólio" \
"Compartilhar o projeto publicamente como marco de conclusão.

**Critério de aceite:**
- [ ] Post publicado com link do repositório" \
"docs" "Sprint 5 — Time Travel + Dashboard + Documentação"

# ---------- Sprint 6 (Bônus) — Lakeflow Declarative Pipelines ----------

create_issue "Estudar tutorial oficial de Lakeflow Declarative Pipelines" \
"Ler a documentação oficial e entender a diferença de sintaxe/paradigma em relação ao pipeline imperativo já construído.

**Critério de aceite:**
- [ ] Notas de estudo registradas" \
"bonus,docs" "Sprint 6 (Bônus) — Lakeflow Declarative Pipelines"

create_issue "Criar pipeline declarativo recriando orders_silver" \
"Usar @dp.materialized_view para recriar a lógica de limpeza de orders_silver em notebooks/bonus_ldp_pipeline/.

**Critério de aceite:**
- [ ] Pipeline declarativo criado e executando com sucesso" \
"bonus,silver" "Sprint 6 (Bônus) — Lakeflow Declarative Pipelines"

create_issue "Adicionar expectativas de qualidade" \
"Usar @dp.expect_or_drop para validar qualidade de dados diretamente no pipeline declarativo.

**Critério de aceite:**
- [ ] Pelo menos 1 expectativa configurada e testada" \
"bonus" "Sprint 6 (Bônus) — Lakeflow Declarative Pipelines"

create_issue "Comparar pipeline declarativo vs imperativo" \
"Rodar as duas versões e comparar tempo de execução, legibilidade do código e facilidade de monitoramento.

**Critério de aceite:**
- [ ] Comparação documentada (tabela ou texto)" \
"bonus,docs" "Sprint 6 (Bônus) — Lakeflow Declarative Pipelines"

create_issue "Escrever seção Imperative vs Declarative no README" \
"Consolidar os aprendizados da sprint em uma seção clara no README.

**Critério de aceite:**
- [ ] Seção publicada no README" \
"bonus,docs" "Sprint 6 (Bônus) — Lakeflow Declarative Pipelines"

# ---------- Sprint 7 (Bônus) — CI com GitHub Actions ----------

create_issue "Adicionar requirements-dev.txt com Ruff" \
"Criar requirements-dev.txt fixando a versão do Ruff (substitui flake8 + black + isort num único binário).

**Critério de aceite:**
- [ ] Arquivo criado na raiz do repositório" \
"bonus,automation" "Sprint 7 (Bônus) — CI com GitHub Actions"

create_issue "Criar pyproject.toml com config do Ruff" \
"Configurar line-length, target-version, select e per-file-ignores compatíveis com o formato de notebook Databricks.

**Critério de aceite:**
- [ ] Seção [tool.ruff] criada em pyproject.toml e testada localmente (ruff check . e ruff format --check .)" \
"bonus,automation" "Sprint 7 (Bônus) — CI com GitHub Actions"

create_issue "Criar workflow .github/workflows/lint.yml" \
"Criar o GitHub Action que roda ruff check e ruff format --check em notebooks/ a cada push/PR na main.

**Critério de aceite:**
- [ ] Workflow criado
- [ ] Action executa com sucesso após primeiro push" \
"bonus,automation" "Sprint 7 (Bônus) — CI com GitHub Actions"

create_issue "Testar o Action com push proposital com erro de lint" \
"Fazer um commit com erro de lint proposital, abrir PR, confirmar que o Action falha; corrigir e confirmar que passa.

**Critério de aceite:**
- [ ] Link do PR que falhou documentado
- [ ] Link do PR que corrigiu documentado" \
"bonus,automation" "Sprint 7 (Bônus) — CI com GitHub Actions"

create_issue "Adicionar badge de status do CI no README" \
"Adicionar o badge do workflow no topo do README, substituindo o placeholder <usuario>.

**Critério de aceite:**
- [ ] Badge visível e funcional no README renderizado no GitHub" \
"bonus,docs" "Sprint 7 (Bônus) — CI com GitHub Actions"

echo ""
echo "==> Concluído! Confira em: https://github.com/$REPO/issues"