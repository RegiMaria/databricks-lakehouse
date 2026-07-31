## Como realizar esse projeto
Para iniciantes

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
- Settings → Developer/Linked accounts → Git integration → escolher GitHub → colar um Personal Access Token
(gerado no GitHub em Settings → Developer settings → Personal access tokens, com permissão repo).

> Consulte a documentação github-token para gerar o Personal Access Token.

**3. Só depois conectar no Databricks**
- No workspace: Workspace -> Repos (ou Git folders) → Add Repo (ou o botão "+" → "Git folder", dependendo da versão da UI)
- Cole a URL do repositório: https://github.com/<seu-usuario>/databricks-lakehouse.git
- Selecione o provider: GitHub
- Confirme o nome da pasta no workspace
Isso faz um clone do repositório dentro do Databricks.
A partir daí, tudo que você criar/editar nos notebooks aparece no painel de Git do Databricks,
pronto pra commitar e dar push direto de lá.
