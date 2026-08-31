# Notas de estudo - Lakeflow Declarative Pipelines

Notas de estudo para a issue #30, preparando a implementação da issue #31
(recriar `orders_silver` como pipeline declarativo).

---

## 1. O que é

Lakeflow Declarative Pipelines é o nome atual do que era conhecido como
**Delta Live Tables (DLT)**. A Databricks renomeou o produto, mas o código
DLT antigo continua funcionando sem migração - mudou principalmente o nome
e a navegação na UI (de "Delta Live Tables" para "Pipelines").

O conceito central: em vez de escrever o **passo a passo** de como processar
os dados (o que fizemos até agora - ler, transformar, escrever), você
**declara** o resultado final de cada tabela como uma query, e o framework
descobre sozinho:

- o grafo de dependências entre as tabelas
- se o processamento deve ser incremental (streaming) ou completo (batch)
- a ordem de execução
- checagens de qualidade de dados
- monitoramento e tratamento de erro

É um nível de abstração acima do que construímos manualmente com o Job do
Databricks Workflows (Sprint 4) - lá, *eu* defini a ordem das tasks
(Bronze → Silver → Gold). No Lakeflow, o framework infere essa ordem a
partir de **quais tabelas leem quais**.

---

## 2. Sintaxe: imperativo (nosso projeto) vs. declarativo (Lakeflow)

| Conceito | Imperativo (o que já fizemos) | Declarativo (Lakeflow) |
|---|---|---|
| Definir uma tabela | `spark.table(...)` + `.write.format("delta").saveAsTable(...)` | `@dp.table()` ou `@dp.materialized_view()` decorando uma função Python |
| Ingestão incremental | Loop manual + `MERGE INTO` (Sprint 2, issue #14) | `@dp.table()` com `spark.readStream` + Auto Loader - o framework cuida do incremental sozinho |
| Qualidade de dados | `.filter(col(...).isNotNull())` manual | `@dp.expect_or_drop("nome_regra", "condição SQL")` - declara a regra, o framework descarta o que não passa |
| Orquestração | Job do Databricks Workflows com tasks e dependências manuais (Sprint 4, issue #20) | Grafo de dependências inferido automaticamente a partir de quais funções leem a tabela de quais outras |
| Onde roda | Notebook comum, executado célula a célula | "Pipeline" - um tipo de execução específico, visualizado como grafo na UI |

### Exemplo de sintaxe (Python)

```python
from pyspark import pipelines as dp
from pyspark.sql.functions import col

# Bronze - ingestão via streaming (Auto Loader)
@dp.table()
@dp.expect_or_drop("valid_order_id", "order_id IS NOT NULL")
def orders_bronze():
    return (
        spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "csv")
        .load("/Volumes/olist_project/bronze/raw_files/olist_orders_dataset.csv")
    )

# Silver - materialized view a partir da Bronze
@dp.materialized_view()
def orders_silver():
    return (
        spark.read.table("orders_bronze")
        .dropDuplicates(["order_id"])
        .filter(col("order_id").isNotNull())
    )
```

Repare que a lógica de limpeza dentro de `orders_silver()` (o `dropDuplicates`
e o `filter`) é **quase idêntica** ao que já escrevemos em
`02_silver_transform.py` - a mudança real está em como a tabela é
**declarada e conectada** ao resto do pipeline (`@dp.materialized_view()`
+ `spark.read.table("orders_bronze")`), não na lógica de limpeza em si.

---

## 3. `@dp.table()` vs. `@dp.materialized_view()`

Pontos a confirmar durante a implementação da issue #31:

- `@dp.table()` parece ser usado para tabelas que processam dados via
  streaming (incremental, ex.: leitura de novos arquivos com Auto Loader)
- `@dp.materialized_view()` parece ser o mais adequado para o nosso caso
  (`orders_silver`), já que estamos recalculando a partir de uma tabela
  Silver existente inteira, não processando um stream de arquivos novos
- **A confirmar na implementação**: qual dos dois efetivamente vamos usar
  para `orders_silver`, e se faz sentido usar `spark.readStream` (como
  Bronze faz na Sprint 1) em vez de `spark.read.table()` para manter a
  natureza incremental que já existe no pipeline imperativo

## 4. `@dp.expect_or_drop` - qualidade de dados embutida

Isso é um diferencial real em relação ao que fizemos manualmente. Em vez de:

```python
.filter(col("order_id").isNotNull())
```

(que só remove nulos, silenciosamente), o Lakeflow permite:

```python
@dp.expect_or_drop("valid_order_id", "order_id IS NOT NULL")
```

Isso declara a regra de qualidade **como metadado do pipeline**, e o
framework não só descarta os registros que falham, como também expõe
métricas de quantos registros foram descartados por qual regra - algo
que teríamos que calcular manualmente (como fizemos no
`02_silver_quality_check.py`, Sprint 2).

Para a issue #32 (adicionar quality expectations), vale explorar aplicar
uma expectation equivalente à validação de FK que já fizemos com
`LEFT ANTI JOIN` na Sprint 2 (issue #13).

---

## 5. Onde isso vai morar no projeto

Conforme já decidido no README, o pipeline declarativo vai ficar em uma
pasta separada, para não misturar com os notebooks imperativos:

```
notebooks/
└── bonus_ldp_pipeline/
    └── orders_silver_declarative.py   (ou nome similar, a definir na #31)
```

---

## 6. Dúvidas / pontos de atenção antes de implementar

- [ ] Confirmar se um pipeline declarativo precisa ser criado como um
      objeto separado do tipo "Pipeline" na UI do Databricks (como o Job
      da Sprint 4), e não apenas rodado como notebook comum
- [ ] Confirmar se `spark.read.table("orders_bronze")` referencia a tabela
      *dentro do próprio pipeline declarativo* ou se precisa apontar para
      `olist_project.bronze.orders` (a tabela real que já existe do
      pipeline imperativo) - provavelmente a segunda, já que estamos
      recriando a lógica em paralelo, não substituindo o pipeline existente
- [ ] Entender se dá para rodar o pipeline declarativo manualmente uma vez
      (modo "Triggered") em vez de deixá-lo populando continuamente, já que
      nosso objetivo é comparação, não substituir o pipeline em produção

---

## 7. Documentação oficial consultada

- [What happened to Delta Live Tables?](https://docs.databricks.com/aws/en/ldp/concepts/where-is-dlt) - contexto da renomeação DLT → Lakeflow
- [Tutorial: Build an ETL pipeline with Lakeflow pipelines](https://docs.databricks.com/aws/en/getting-started/data-pipeline-get-started) - tutorial oficial passo a passo
- [Develop pipeline code with Python](https://docs.databricks.com/aws/en/ldp/developer/python-dev) - sintaxe de `@dp.table`, `@dp.materialized_view`, `@dp.expect_or_drop`
- [Tutorial: Create your first pipeline using the Lakeflow Pipelines Editor](https://docs.databricks.com/aws/en/ldp/tutorial-get-started) - editor visual, alternativa ao código puro

---

## Próximo passo

Issue #31 - implementar o pipeline declarativo recriando `orders_silver`,
usando estas notas como referência de sintaxe e resolvendo os pontos em
aberto da seção 6 durante a implementação.