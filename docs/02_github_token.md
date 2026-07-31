## Gerando o Fine-grained Personal Access Token (escopo mínimo)
O GitHub tem dois tipos de token: o "classic" (que dá acesso amplo, tipo tudo-ou-nada no escopo repo)
e o fine-grained (que permite restringir a um repositório específico e a permissões granulares).
Pra escopo mínimo de verdade, vamos usar o fine-grained.

**Passo a passo:**
1. No GitHub:
- clique na sua foto de perfil → Settings
- Developer settings (no menu lateral, no final)
- Personal access tokens → Fine-grained tokens
- Generate new token

---
<div align="center">
  <img src="https://github.com/user-attachments/assets/d70080d8-0bdc-4b4e-bcb0-3af827f75c42" width="650"/>
</div>

---

2. Preencha:
- Token name: algo identificável, ex: databricks-olist-lakehouse
- Expiration: recomendo 90 dias em vez do padrão de 30 evita ter que renovar toda hora
durante o projeto, mas ainda expira (boa prática vs. token eterno)
- Repository access: selecione "Only select repositories" e marque só o databricks-lakehouse isso
é o coração do "escopo mínimo": selecione **apenas os repositórios necessários pro controle de versão do Git folder Databricks**
- Em Permissions, clique em **Add permissions** e configure: defina **Contents** como Read and write.
- Em Permissions, clique em **Add permissions** e configure:: defina **workflow do GitHub Actions** (.github/workflows/lint.yml) 
Read and write.

---

<div align="center">
  <img src="https://github.com/user-attachments/assets/ffc6de22-0922-4c2b-ad4f-392a9b8c6beb" width="700"/>
</div>

---

>Sem isso, a gente não conseguiria commitar/pushar mudanças no arquivo `.github/workflows/lint.yml` de dentro do Databricks, pois a Databricks GitHub App não tem permissão pra modificar arquivos de workflow do GitHub Actions no diretório `.github/workflows/


Isso é literalmente tudo que a gente  precisa pro fluxo normal (clone, commit, push, pull, branch).

**Resumo do escopo mínimo**

| Permissão             | Nível                          | Por quê?                                                                                          |
| :-------------------- | :----------------------------- | :------------------------------------------------------------------------------------------------ |
| **Repository access** | Somente `databricks-lakehouse` | Nunca conceda acesso a todos os repositórios. Siga o princípio do menor privilégio.               |
| **Contents**          | **Read and write**             | Necessário para operações Git como `clone`, `pull`, `push`, `commit` e gerenciamento de branches. |
| **Workflows**         | **Read and write**             | Necessário para interagir com os arquivos em `.github/workflows/`, como o `lint.yml` da Sprint 7. |

3. Depois de gerar o token
- Depois de gerar o token em Generate token
- Copie o token (só aparece uma vez!)

Vamos colar esse token na Databricks:

- → Settings 
- → Linked accounts
- → Add Git credential
- Provider: GitHub

 Siga para a documentação 03_Databricks_add_git_credential.md

