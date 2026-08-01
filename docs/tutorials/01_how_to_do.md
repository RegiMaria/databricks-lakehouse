## Sprint 1: Setup de ambiente + bronze

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

Pode comemorar! Vamos pra Sprint 2.
