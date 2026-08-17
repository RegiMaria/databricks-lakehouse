## Sprint 1: Setup de ambiente + bronze

---
**Objetivo**: ambiente funcionando e dados brutos como` Delta Table`, sem transformação.

**1. Criar o repositório no GitHub primeiro**
- Vá em GitHub -->  New repository
- Nome: databricks-lakehouse (ou como preferir)
- Adicione o `.gitignore`
- Visibilidade: público, se é pra portfólio

**2. Clonar localmente (opcional, mas recomendado)**
```bash
git clone https://github.com/<seu-usuario>/databricks-lakehouse.git
cd databricks-lakehouse
```
**3. Antes de ir pro passo 4**

Antes de ir pro passo 4 e conectar seu repositório no Github com Databricks,
você precisa configurar as credenciais Git no Databricks (uma vez só, vale pra todos os repositórios):
- Settings
- → Developer/Linked accounts
-  → Git integration → escolher GitHub
-  → colar um Personal Access Token
(gerado no GitHub em Settings → Developer settings → Personal access tokens, com permissão repo).

Consulte a documentação 01-github-token para gerar o Personal Access Token.

**4. Só depois conectar no Databricks**

- No workspace: Workspace -> Repos (ou Git folders) → Add Repo (ou o botão "+" → "Git folder", dependendo da versão da UI)
- Cole a URL do repositório: https://github.com/<seu-usuario>/databricks-lakehouse.git
- Selecione o provider: GitHub
- Confirme o nome da pasta no workspace

Isso faz um clone do repositório dentro do Databricks.
A partir daí, tudo que você criar/editar nos notebooks aparece no painel de Git do Databricks,
pronto pra commitar e dar push direto de lá.

Veja essa passo a passo mais detalho em 03_databricks_add_git_credential

**5. Atualize o repositório na Databricks**

Na Databricks, atualize o repositório:
- No seu repo clique no símbolo de git
- Verifique se está na main
- Clique em Pull
- Deve aparecer suas branches e arquivos atualizados

[ imagem 05]


### Cria catálagos e schemas

**1. Crie uma nova branch**
Sugestão `feature/setup-catalog-schemas`

**2. Crie um novo diretório**
notebooks/
 Dentro dele
- Crie um arquivo .py chamado `00_setup.py`
- O `00_setup.py` cria atalog, schemas, volume

**3. Sobre volumes e tabelas**

![Database objects in Databricks](https://docs.databricks.com/aws/en/assets/images/object-model-volume-d472dba24dca8002ff629cde896d4753.png)

Volume ≠ Tabela: são coisas diferentes

No Unity Catalog, existem dois tipos de objeto pra guardar dado, com propósitos bem distintos:

| Característica | Volume | Tabela (Delta) |
|----------------|--------|----------------|
| **O que armazena** | Arquivos brutos (CSV, JSON, imagens, PDFs...) | Dados estruturados em formato colunar (Delta) |
| **Tem schema?** | ❌ Não - é apenas um sistema de arquivos governado | ✅ Sim - possui colunas, tipos de dados e schema definido |
| **Consulta com SQL?** | ❌ Não diretamente | ✅ Sim (`SELECT * FROM tabela`) |
| **Suporta ACID e Time Travel?** | ❌ Não | ✅ Sim |

Volumes governam dados não-tabulares. Pense neles como uma "pasta" dentro do Unity Catalog,
só que com governança (permissões, auditoria) aplicada. 
Não são consultáveis com SQL porque não têm estrutura de colunas, são só arquivos.

**Por que criamos Volume agora, e Tabela depois**

Isso é literalmente o fluxo da Fase 1 (Bronze) do nosso plano, só que dividido em duas etapas:

**Etapa 1** (agora, `00_setup.py`): criar o Volume, é só um "local de pouso" pros arquivos CSV brutos,
exatamente como estão, sem transformação nenhuma. Você faz upload dos 8 CSVs pra lá.

**Etapa 2** (próxima, `01_bronze_ingestion.py`): ler os CSVs que estão no Volume e escrever como Tabela Delta.
É aqui que o dado passa de "arquivo solto" pra "tabela consultável com SQL, versionada, com ACID".

Em resumo:

`Volume` é só a porta de entrada dos arquivos brutos no Lakehouse,
a "Camada Bronze" de verdade, no sentido de tabela Delta consultável,
só nasce depois, na próxima etapa (`01_bronze_ingestion.py`, issue #7).

Para saber mais:

- Sobre Catalog, Schemas e volulmes:
[Databricks Unity Catalog objects
](https://docs.databricks.com/aws/en/volumes/)

- O que é ACID
[What is ACID?](https://www.databricks.com/blog/what-are-acid-transactions)

**4. Upload dos CSVs pro Volume**

No Databricks:
- Catalog
- → olist_project
- → bronze
- → raw_files 
- → Upload to this volume 
- → selecione os 8 CSVs.

Confirme que todos os 8 apareceram lá antes de seguir (issue #5 concluída)

Antes de criamos o notebook de ingestão, vamos commitar o notebook  `00_setup.py`

**5. Commitando na Databricks**

5.1. Com o notebook `notebooks/00_setup.py` já criado e salvo, olhe no canto superior do workspace (perto do nome do arquivo/pasta)
tem um ícone de `branch/Git` mostrando algo como `feature/setup-catalog-schemas` com um número ao lado (indicando quantas mudanças pendentes).
Clique nesse ícone.

Abre um painel lateral (geralmente à direita) mostrando os arquivos alterados
Confirme que só o `00_setup.py está marcado/selecionado` (se aparecer outra coisa junto que você não quer commitar ainda, desmarque)

No campo de mensagem de commit, escreva:

`feat: cria catalog, schemas e volume via notebook versionado`

**5.2 - Clique no botão `Commit & Push`**

Depois de commitar

Confirme que funcionou olhando o histórico,
ou no próprio painel do Databricks (geralmente mostra "up to date" ou similar),
ou voltando pro GitHub e conferindo se o commit apareceu na branch `feature/setup-catalog-schemas`:

No github:

`https://github.com/<seu-usuario>/<nome-do-seu-projeto>/commits/feature/setup-catalog-schemas`

ANtes de seguirmos pra ingestão `01_bronze_ingestion.py`, vamos fazer uma Pull Requests.

**6. Criando Pull Requests**

Dentro do Databricks, não existe Pull Requests.
Merge de Pull Request é uma operação do GitHub, não do Databricks.
A Databricks só faz clone/pull/commit/push/criar branch,
a parte de revisar e mergear PR acontece sempre no GitHub (site ou CLI), nunca na interface do Databricks.

Já que seu push de `feature/setup-catalog-schemas` já está no GitHub, é só:

1. Abra: https://github.com/<seu-usuario>/<nome-projeto>/pull/new/feature/setup-catalog-schemas
2. Confirme: base = develop (ou main, dependendo do seu fluxo), compare = feature/setup-catalog-schemas
3. Título: feat: cria catalog, schemas e volume via notebook versionado
4. Escreva o corpo da PR
5. Clique Create pull request
6. Na tela seguinte, clique Merge pull request → Confirm merge

**7. Atualizar respoitório Databricks**

Na Databricks: 
1. Abra o Git folder do projeto (databricks-lakehouse) no Workspace
2. Confirme em qual branch ele está parado (aquele indicador no canto superior)
3.Importante: Se quer o estado mais atualizado e "oficial" → troque pra main ou branch mais atualizada
4. Se vai continuar trabalhando em cima do que está em progresso → develop
5. Pra trocar de branch: clique no seletor de branch (mesmo ícone de Git) → escolha main (ou develop) na lista
6. Depois de selecionar a branch certa, clique em `Pull`
Confirme que funcionou

Depois do Pull, navegue pela pasta do projeto e confira se `notebooks/00_setup.py` está lá,
e se os arquivos de doc/scripts também apareceram.


**8. Criar o notebook `notebooks/01_bronze_ingestion.py`**

Dentro do seu Git folder `Notebooks/` na Databricks (nova branch `feature/bronze-ingestion`), crie:

- Notebook `01_bronze_ingestion.py`
- Rode o notebook

- Faça PR no github para sua `main` ou `develop`.
- Na Databricks cria nova branch `docs/data_dictionary`.
- Adiciona em `docs/data_dictionary.md`

**9. Criar o dicionário de dados**
- Adiciona em `docs/data_dictionary.md`


**O que é um dicionário de dados**

É um documento que descreve o que cada tabela e cada coluna significam, não o dado em si (os valores),
mas o metadado: nome, tipo, o que representa, como se relaciona com outras tabelas.
É, literalmente, um "dicionário" no sentido comum: você procura uma palavra (nome de coluna) e encontra a definição dela.

No nosso caso: alguém abre `docs/data_dictionary.md` e descobre, sem precisar rodar nenhuma query,
que `customer_unique_id` é diferente de `customer_id`, ou que `order_items` tem chave composta,
informação que só é óbvia depois de estudar o dataset a fundo.

**Por que isso importa (o problema que resolve)**

Pense no cenário sem esse documento: você (ou qualquer outra pessoa) abre a tabela products daqui a 3 meses
e vê uma coluna chamada product_name_lenght. Primeira reação: "isso é um erro de digitação meu?"
Sem o dicionário, você perde tempo investigando, olhando o CSV original, sem saber se é bug seu
ou característica da fonte. Com o dicionário, a resposta já está documentada: é um typo do dataset
original, mantido de propósito.

Outro exemplo real do nosso próprio documento: geolocation tem múltiplas linhas por CEP.
Se alguém (você, sua colega) for fazer um JOIN com essa tabela sem saber disso,
o resultado vai "explodir" (multiplicar linhas inesperadamente)
e vai levar um tempo pra descobrir por quê.
O dicionário avisa isso antes do problema acontecer.

**Por que fizemos isso especificamente agora**

Alinhando com o motivo original (issue #8, ainda na Sprint 1): a ideia é documentar a estrutura
logo depois da ingestão Bronze, enquanto os dados ainda estão "crus", é o momento em que a gente
mais precisa entender a fonte, antes de começar a limpar e transformar nas próximas sprints (Silver, Gold).
Documentar cedo evita que decisões de limpeza sejam feitas no escuro.

**No que ajuda, na prática**

Serve de referência pra você mesma nas próximas sprints, quando for escrever o` 02_silver_transform.py`,
você não precisa reabrir o CSV pra lembrar quais colunas existem e o que significam
Documenta decisões de qualidade de dados antes de virar bug.a seção final ("observações de qualidade")
já avisa coisas tipo "datas nulas em orders são esperadas, não é erro",isso evita que você (ou alguém revisando seu código)
trate um caso normal como se fosse falha.

**Portfólio/entrevista:**

Pode mostrar que você entende o dado antes de programar em cima dele, é uma das diferenças entre "sei escrever PySpark"
e "sei fazer engenharia de dados de verdade", que exige entender a fonte, não só a sintaxe.

**Para Onboarding de terceiros**: 

Se você trouxer um colaborador ou alguém clonar o repositório, esse documento é o primeiro lugar que explica "o que é esse dado", sem precisar te perguntar.

### O que fizemos até agora

✅ #1 Repositório criado

✅ #2 Unity Catalog confirmado

✅ #3 Git folder conectado

✅ #4 Catalog/schemas/volume criados

✅ #5 CSVs no Volume

✅ #6 00_setup.py

✅ #7 01_bronze_ingestion.py

✅ #8 data_dictionary.md


Pode comemorar! Vamos pra **Sprint 2.**

## Sprint 2: Camada Silver

---
**Objetivo**: dados limpos, tipados, deduplicados, com upsert via `MERGE INTO`.

- Na Databricks na branch `main` faça `Pull`.
- Cria uma nova branch `feature/silver-transform`. Confirme que está na branch nova.
- Adicione em `notebooks/notebooks/02_silver_transform`

Nossa tarefa nessa Issue é:
- `notebooks/02_silver_transform` com:
- zero duplicatas confirmado com queries de validação
- e as 5 colunas de data aparecem como `timestamp` no `DESCRIBE`

**Resumo da lógica:**

Bronze (dado bruto, tipos inferidos, duplicatas possíveis) 
→ `dropDuplicates` por chave 
→ `conversão de tipo` nas `datas` 
→ filtro de **nulo SÓ em colunas que são obrigatórias de verdade **
→ Silver (dado confiável, mas ainda sem lógica de negócio)

**Próxima Issue:**

- Limpeza de customers, products, sellers

### Limpeza de customers, products e selles
**Tabela customers**

Vamos usar o mesmo notebook de `notebooks/02_silver_transform.ipynb`.

Abra uma branch nova:
`feature/silver-customers-products-sellers`

Primeira parte do código / primeira célula

**1.Tabela customers**

Pegaremos a tabela `customers` da camada Bronze (como veio, sem tratamento),
removemos linhas com `customer_id` duplicado, descartamos linhas sem `customer_id` (dado inválido),
e salvamos o resultado como uma nova tabela `Delta` na camada Silver. O print final serve só pra confirmar visualmente quantas linhas sobreviveram depois da limpeza.

Ponto de atenção:
`.write.format("delta")` → salva no formato Delta Lake, não CSV/Parquet puro
`.mode("overwrite")` → substitui a tabela inteira se ela já existir, em vez de duplicar, é o que torna o notebook [idempotente](https://www.freecodecamp.org/news/idempotence-explained/) (rodar várias vezes dá o mesmo resultado)
`.saveAsTable("olist_project.silver.customers")` → registra oficialmente no[ Unity Catalog](https://docs.databricks.com/aws/en/data-governance/unity-catalog/), dentro do schema silver

Faça o commit: `feat: limpeza de customers`

Agora vamos para tabela products

### Tabela products

**2. Tabela products**

O que faremos:

Vamos ler a tabela `products` da camada Bronze, exatamente como veio da ingestão. Sem nenhuma limpeza ainda.
Vamos realizar duas operações encadeadas:

.dropDuplicates(["product_id"]) → remove linhas com product_id repetido, mantendo só uma ocorrência de cada produto

.filter(col("`product_id`").isNotNull()) → descarta linhas onde `product_id` é nulo (produto sem identificador não é um registro válido)

Salvaremos o resultado como tabela Delta em `olist_project.silver.products`, sobrescrevendo se já existir (idempotência).

**Um ponto que vale destacar:**

A estrutura do problema é a mesma: uma tabela de catálogo (produto, cliente, vendedor, todas são "tabelas de dimensão",
no sentido do `star schema` que vamos montar na Sprint 3), onde a única coisa que precisa de garantia é:
uma linha por chave, sem chave nula.

Não tem coluna de `data` aqui, então a gente não precisa do loop de `to_timestamp` que usamos em `orders`.


**Outro ponto que vale destacar sobre products especificamente:**

Lembra que sobre `product_category_name`, ele poder ser `nulo` (problema conhecido do dataset)?
Repare que não filtramos por essa coluna, só por `product_id`.

Isso é proposital: um produto sem categoria ainda é um produto válido (é só um dado incompleto, não um erro estrutural).
Se filtrássemos por `product_category_name`, perderíamos produtos legítimos só por falta de categorização,
mesma lógica que aplicamos com as datas de orders, só que agora pra outra coluna "opcional".

**O que você deve esperar do print**

Deve sair algo como:

`products_silver: 32951 linhas`

Esse número é menor que o de customers (99441) porque no Olist há muito menos produtos únicos do que pedidos/clientes,
cada produto pode ser vendido em múltiplos pedidos diferentes.

### Tabela sellers

**Tabela sellers:**

O que faremos:
- Lê sellers da Bronze
- Remover duplicatas por seller_id (garante chave única)
- Descartar linhas com seller_id nulo (dado inválido)
- Salvar como Delta em olist_project.silver.sellers, sobrescrevendo se já existir
- Imprimir a contagem final como confirmação

**Um ponto a destacar:**

De acordo com nosso dicionário de dados, `sellers` só tem 4 colunas no total (seller_id, CEP, cidade, estado),
nenhuma data, nenhum campo "opcional" com nulos esperados tipo o `product_category_name`.
É a tabela de dimensão mais direta de limpar: só garantir chave única e não-nula, ponto final.

**O que esperar do print**

No dataset Olist, o número de vendedores costuma ser bem menor que produtos ou clientes algo na casa de ~3000.
Se sair um número muito diferente disso (tipo próximo de 99441, igual customers),
vale desconfiar que algo foi copiado/colado errado da célula anterior.

### Query de validação

O que essa query faz

Ela roda a mesma checagem de duplicata três vezes (uma por tabela) e junta os resultados numa lista só, usando UNION ALL.

```sql
SELECT 'customers' as tabela, customer_id as chave, COUNT(*) as qtd
FROM olist_project.silver.customers
GROUP BY customer_id
HAVING COUNT(*) > 1
```

Isso agrupa a tabela customers por `customer_id` e só mantém os grupos que têm mais de 1 linha (HAVING COUNT(*) > 1),
ou seja, só aparece aqui se existir uma duplicata de verdade. A coluna 'customers' (texto fixo)
serve só pra identificar de qual tabela veio aquela linha no resultado final.

```sql
sql
UNION ALL
SELECT 'products', product_id, COUNT(*)
FROM olist_project.silver.products GROUP BY product_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'sellers', seller_id, COUNT(*)
FROM olist_project.silver.sellers GROUP BY seller_id HAVING COUNT(*) > 1
```
UNION ALL empilha os resultados das três consultas, uma embaixo da outra, num resultado único.

**Como interpretar o resultado**

Se a query não retornar nenhuma linha (resultado vazio) → ótimo,
significa que nenhuma das três tabelas tem chave duplicada. 
 o resultado esperado, e é o que confirma o critério de aceite da issue #10.

Se aparecer alguma linha → tipo customers | abc123 | 2
significaria que sobrou uma duplicata em customers pro customer_id "abc123",
o que indicaria que algo deu errado na limpeza (não deveria acontecer,
já que rodamos dropDuplicates antes).

Em vez de rodar 3 células de validação separadas (uma por tabela),
essa junta tudo numa consulta só, mais rápida de ler o resultado de uma vez.

## Tabelas order_items e order_payments
Até agora (orders, customers, products, sellers), cada tabela tinha uma chave primária simples (order_id, customer_id, etc.), uma coluna, um valor único por linha, certo?

`order_items` e `order_payments` são diferentes: não têm chave primária de coluna única. Olhando o dicionário de dados:

order_items → chave é a combinação de (order_id, order_item_id) — porque um pedido pode ter vários itens, então order_id sozinho se repete várias vezes de propósito (isso é esperado, não é duplicata "errada")
order_payments → chave é a combinação de (order_id, payment_sequential) — porque um pedido pode ter vários pagamentos (ex: parcelado em cartão + voucher), então order_id também se repete de propósito.

** Chave composta**

Isso muda a lógica de `dedup`. Se a gente fizesse `dropDuplicates`(["order_id"]) aqui, do jeito que fizemos nas tabelas anteriores, destruiríamos o dado, apagaríamos itens/pagamentos legítimos só porque compartilham o mesmo `order_id`. O dedup precisa ser pela chave `composta inteira`, não só por order_id.

O que vamos fazer:

1. Ler `order_items` e order_payments da Bronze
2. Fazer dedup pela chave composta, não coluna única
3. Filtrar nulo em `order_id` (chave obrigatória em ambas)
4. Escrever como Delta em `olist_project.silver`
5. Validar FK: rodar um `anti-join` checando se existe algum `order_id` em `order_items/order_payments` que não existe em `silver.orders`

Sugestão para nome da branch:
```
feature/silver-order-items-payments
```

Agoa vamos rodar o `notebook/02_silver_transform.py` com a lógica de 
chave composta e a validação de FK.

**02c - Silver Transform: order_items, order_payments**

Diferente das tabelas anteriores, order_items e order_payments
têm chave composta (não uma coluna única),` order_i`d se repete
de propósito, pois um pedido pode ter múltiplos itens/pagamentos.

## order_items

```python   
order_items_bronze = spark.table("olist_project.bronze.order_items")

order_items_silver = (
    order_items_bronze
    .dropDuplicates(["order_id", "order_item_id"])
    .filter(col("order_id").isNotNull())
)

(
    order_items_silver.write.format("delta")
    .mode("overwrite")
    .saveAsTable("olist_project.silver.order_items")
)

print(f"order_items_silver: {order_items_silver.count()} linhas")

```
## order_payments

```
order_payments_bronze = spark.table("olist_project.bronze.order_payments")

order_payments_silver = (
    order_payments_bronze
    .dropDuplicates(["order_id", "payment_sequential"])
    .filter(col("order_id").isNotNull())
)

(
    order_payments_silver.write.format("delta")
    .mode("overwrite")
    .saveAsTable("olist_project.silver.order_payments")
)

print(f"order_payments_silver: {order_payments_silver.count()} linhas")
```
## Validação
```
-- Critério de aceite: zero duplicatas pela chave composta
SELECT order_id, order_item_id, COUNT(*) as qtd
FROM olist_project.silver.order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
```

```
%sql
 SELECT order_id, payment_sequential, COUNT(*) as qtd
 FROM olist_project.silver.order_payments
 GROUP BY order_id, payment_sequential
 HAVING COUNT(*) > 1;

```
```
-- Critério de aceite: FK order_id validada contra silver.orders
-- Anti-join: encontra order_id em order_items que NÃO existe em orders
SELECT oi.order_id
FROM olist_project.silver.order_items oi
LEFT ANTI JOIN olist_project.silver.orders o
ON oi.order_id = o.order_id;

```
```
-- Mesma checagem para order_payments
SELECT op.order_id
FROM olist_project.silver.order_payments op
LEFT ANTI JOIN olist_project.silver.orders o
ON op.order_id = o.order_id;
```

Faça o commit!

Por que usamos `LEFT JOIN` + filtro no nosso caso

Poderíamos ter escrito:

```
SELECT oi.order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

```

O `LEFT JOIN` Retorna todas as linhas da esquerda, e preenche com NULL onde não achar correspondência na direita,certo?

```
SELECT * FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id;
```

Resultado: `A` (com dado de orders), `X` (com colunas de orders vindo NULL, porque não achou). Repare: isso traz as colunas de `orders` junto, mesmo quando **não existe correspondência**, você precisaria depois **filtrar** **manualmente**` WHERE o.order_id IS NULL` pra achar só os órfãos.

LEFT ANTI JOIN - o que usamos

Já faz o trabalho que a gente teria que fazer manualmente com `LEFT JOIN + WHERE ... IS NULL`, só que direto:

```
SELECT oi.order_id
FROM order_items oi
LEFT ANTI JOIN orders o ON oi.order_id = o.order_id;
```

Resultado: só `X` só os órfãos, e só as colunas de `order_items` (nem traz colunas de `orders`, porque não faz sentido trazer colunas de algo que não existe pra aquela linha).

coloca em tabela markdown


Resumindo a diferença de propósito

| JOIN        | O que retorna                                                     | Pra que serve aqui                                       |
| ----------- | ----------------------------------------------------------------- | -------------------------------------------------------- |
| `INNER`     | Só o que casa nos dois lados                                      | Combinar dados relacionados                              |
| `LEFT`      | Tudo da esquerda + o que casar da direita (`NULL` onde não casar) | Enriquecer dados, mantendo tudo da tabela principal      |
| `RIGHT`     | Tudo da direita + o que casar da esquerda                         | Mesmo que `LEFT`, só que invertido                       |
| `LEFT ANTI` | **Só** o que **não** casou                                        | Achar registros órfãos e validar integridade referencial |

Ainda no notebook `02_silver_transform.py`
 vamos para a Etapa 4 (MERGE INTO).

**MERGE INTO é conceitualmente diferente**

As etapas 1-3 foram todas a mesma operação repetida: ler Bronze → limpar → overwrite na Silver. A issue #14 é outra coisa, é simular uma** atualização incremental** (um "novo batch" chegando depois que a tabela já existe) e fazer um` upsert com MERGE INTO`, que é bem diferente de `overwrite`. Entenda que esse é um conceito novo, não é só "mais uma tabela limpa da mesma forma.

## Simular carga incremental + MERGE INTO

Antes que qualquer coisa, depois de escrever sua `PR`, volte pra `main` e cria uma nova branch `feature/silver-merge-into`, é opcional.


**MERGE INTO**

essa é provavelmente a feature mais "cartão de visita" de todo o Delta Lake, vale o tempo de entender bem o conceito.

**O que é "carga incremental"**

Até agora, todo notebook que escrevemos usou mode("overwrite"), ou seja, toda vez que rodava, apagava a tabela inteira e recriava do zero a partir da Bronze. Isso funciona bem quando você está processando "tudo de novo", mas não é assim que dado funciona no mundo real.

Na vida real, um sistema de vendas gera pedidos novos todo dia. Você não quer reprocessar 99 mil pedidos antigos toda vez que 50 pedidos novos chegam — isso seria lento, caro (processamento desnecessário) e, em sistemas de verdade (com milhões/bilhões de linhas), simplesmente inviável.

Carga incremental é o padrão de só processar o que mudou desde a última execução: os registros novos (inserir) e os que foram atualizados (atualizar), **sem tocar no resto.** 
É assim que pipelines de produção funcionam, rodando de hora em hora ou diariamente, sempre processando só o "delta" (a diferença) desde a última rodada.

**Por que isso é importante de aprender**

Porque é o cenário que você vai encontrar em praticamente todo emprego de engenharia de dados. Ninguém reprocessa a tabela inteira do zero toda hora — isso é o que separa um exercício de faculdade ("processe esse CSV uma vez") de um pipeline de produção de verdade ("processe os pedidos que chegaram nas últimas 24h, todo dia, para sempre"). É também o motivo de existir `Delta Lake` em primeiro lugar, CSV/Parquet puro não têm um jeito nativo e seguro de fazer isso.

**O que é MERGE INTO**

É o comando que resolve exatamente esse problema: você compara um conjunto de dados "novo" (o batch incremental) contra a tabela existente, e diz: "se o registro já existe (mesma chave), atualiza; se não existe, insere". Essa operação tem nome técnico: upsert (update + insert).


```

MERGE INTO tabela_destino AS target
USING dados_novos AS source
ON target.chave = source.chave
WHEN MATCHED THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *
```
**Por que MERGE INTO, e não outras formas**

Existem outras abordagens possíveis, mas cada uma tem um problema sério:

1. mode("append") - só adiciona linhas novas, sem checar duplicata. Problema: se você rodar duas vezes com o mesmo batch (por engano, ou porque o job travou e reiniciou), você duplica os dados. Não resolve o caso de "atualizar um pedido que mudou de status".

2. Apagar tudo e reprocessar (overwrite, como fizemos até agora) - funciona, mas não escala. Reprocessar tabelas de bilhões de linhas toda hora é caro e lento.

3. Lógica manual em duas etapas (fazer um DELETE dos registros que vão mudar, depois um INSERT dos novos) - tecnicamente possível, mas não é atômico: se o processo cair no meio (entre o DELETE e o INSERT), você fica com dado inconsistente - registros que sumiram e ainda não voltaram.

`MERGE INTO` resolve os três problemas de uma vez: é atômico (ou a operação inteira funciona, ou nada muda - graças às garantias [`ACID` do `Delta Lake`](https://docs.databricks.com/aws/en/lakehouse/acid) que vocês já estudaram), lida com update e insert no mesmo comando, e não duplica se rodado de novo com o mesmo dado (porque compara pela chave).

**Como vamos simular isso no nosso projeto**

Como não temos um sistema real gerando pedidos novos a cada minuto, vamos simular esse cenário:

1. Pegar um pequeno subconjunto da tabela orders (por exemplo, 100 pedidos)
2. "Fingir" que alguns já existiam (serão atualizados, ex: mudou o order_status) e outros são novos (serão inseridos)
3. Rodar MERGE INTO contra silver.orders
4. Confirmar com `DESCRIBE HISTORY` que a operação ficou registrada como uma versão nova da tabela

**Sobre o nosso critério de aceite "DESCRIBE HISTORY mostra a operação registrada"**

Isso conecta direto com o `Time Travel` que vamos explorar na Sprint 5 - cada `MERGE INTO` cria uma nova versão da tabela Delta, com timestamp, operação e detalhes de quantas linhas foram inseridas/atualizadas. É esse histórico versionado que depois vai permitir "voltar no tempo" se algo der errado.


## Auditoria final
Abra uma nova branch chamada 
`feature/silver-quality-check`.

Crie um novo notebook chamado `02_silver_quality_check`.

Esse notebook novo (`02_silver_quality_check.py`) vai servir  como uma **auditoria** final da camada Silver inteira: pra cada uma das 6 tabelas que processamos, compararemos:

- Quantas linhas tinha na Bronze vs. quantas sobraram na Silver (quanto foi descartado, e se essa quantidade faz sentido)
- Quantos nulos existiam nas colunas-chave antes vs. depois (deve ir a zero depois)
- Quantas duplicatas existiam antes vs. depois (idem)

**Por que isso é importante**

1. Detecção de regressão - se algum dia a gente alterar a lógica de limpeza (numa Sprint futura, ou revisando o código), esse notebook funciona como um "teste automatizado informal": rodar ele de novo revela na hora se alguma tabela quebrou o padrão esperado.

2. Evidência auditável, num lugar só - em vez de vasculhar 4 PRs diferentes procurando "cadê a prova de que orders ficou limpo", você tem um relatório único, consolidado, que qualquer pessoa (ou você mesma, meses depois) consulta pra confirmar a qualidade de toda a camada de uma vez.

3. Antes de avançar pra Gold, você quer ter certeza - a camada Gold vai fazer JOINs entre essas tabelas. Se alguma tiver um problema de qualidade não detectado, ele se propaga e vira um bug muito mais difícil de rastrear lá na frente. Esse notebook é o "portão de qualidade" antes de seguir adiante.


Depois de rodar o notebook:

**Como interpretar o resultado esperado**

- A primeira query (resumo Bronze vs Silver) deve mostrar linhas_descartadas baixo ou zero pra maioria, grandes descartes indicariam algo errado na limpeza.

- A segunda query (duplicatas) deve vir toda zerada - já validamos isso individualmente, aqui é só a confirmação consolidada.

- A terceira query (nulos) também deve vir toda zerada - mesma lógica.

Sobre:

`orders: bronze_linhas=99441, silver_linhas=99446, descartadas=-5`

Repare: descartadas deu negativo (-5), o que significa o oposto de "descartado" - a tabela Silver tem 5 linhas a mais que a Bronze, não a menos.

**Por que isso é esperado (e não um erro)**

Lembra da Etapa 4? Nós simulamos um batch incremental e usamos MERGE INTO pra inserir 5 pedidos fictícios novos (sim_001 a sim_005) direto na tabela Silver.

Esses 5 registros nunca existiram na Bronze, eles foram criados artificialmente, direto na Silver, como parte da simulação. Por isso a Silver ficou com 99.446 linhas (99.441 originais + 5 simulados), enquanto a Bronze continua com 99.441 (porque a Bronze nunca foi tocada pelo MERGE INTO).

Adicione uma nota no seu notebook:
> **Nota sobre `orders`:** o valor negativo em `linhas_descartadas` (-5) é esperado - não indica erro.
> Reflete os 5 pedidos simulados (`sim_001` a `sim_005`) inseridos via `MERGE INTO` na Etapa 4,
> que existem na Silver mas nunca passaram pela Bronze.

Escreva a Pull Requests `feature/silver-quality-check → develop` ou/ e `develop → main`.

## Sprint 3 - Modelar Star Schema e Noteboo de agregação da tabela Fato fact_orders

### 1.Tabela Fatp fact_orders

Crie uma nova branch `feature/gold-fact-orders`
Crie um novo `notebook/3_gold_aggregation.py`

**O que vamos fazer, e por quê**

Chegou a hora de construir a tabela fato (fact_orders) que desenhamos no star_schema.md. Diferente das etapas anteriores (que só limpavam uma tabela por vez), aqui vamos fazer o primeiro JOIN de verdade do projeto, juntar silver.orders com silver.order_items pra chegar na granularidade certa (1 linha por item de pedido, não por pedido).
**
Por que a granularidade importa**

Se a gente usasse só silver.orders, teria 1 linha por pedido , mas um pedido pode ter vários itens, cada um com seu próprio price. Pra conseguir somar receita corretamente (por produto, por vendedor), a fato precisa estar no nível de item, que é o que order_items já tem. É por isso que o JOIN parte de order_items como base e traz os dados de orders pra cada linha.

**Por que inner join, e não left**
Usamos how="inner" de propósito: só queremos itens que têm um pedido válido correspondente. Lembra do LEFT ANTI JOIN que fizemos na Etapa 3 pra garantir que não existiam itens órfãos? Isso significa que, nesse ponto, inner e left dariam o mesmo resultado — mas inner deixa a intenção mais clara: "eu exijo que a correspondência exista", em vez de "eu aceito não achar e preencho com nulo".

**O que esperar dos números**
fact_orders deve ter 112.650 linhas (mesmo total de order_items, já que a granularidade é a mesma)
pedidos_unicos deve ficar próximo de 99.441-99.446 (o número de pedidos distintos, considerando os simulados da Etapa 4).

Essa é a primeira vez no projeto que combinamos duas tabelas numa só, é literalmente o que separa "dados limpos" (Silver) de "dados prontos pra análise de negócio" (Gold): a Gold junta as peças pra responder perguntas reais, tipo "quanto vendemos por categoria de produto no último trimestre".

### 2. Criar tabelas dimensão na camada gold

Dimensões: dim_customer, dim_product, dim_seller




