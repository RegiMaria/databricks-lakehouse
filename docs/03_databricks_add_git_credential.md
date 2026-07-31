## Databricks Add Git credential
1.No Workspace

- No workspace: Workspace -> Repos (ou Git folders) → Add Repo (ou o botão "+" → "Create Git folder", dependendo da versão da UI)
- Cole a URL do repositório: https://github.com/<seu-usuario>/databricks-lakehouse.git
- Selecione o provider: GitHub
- Confirme o nome da pasta no workspace
[ imagem 03 aqui]

Isso faz um clone do repositório dentro do Databricks.
A partir daí, tudo que você criar/editar nos notebooks aparece no painel de Git do Databricks,
pronto pra commitar e dar push direto de lá.

2. Databricks
Na hora de empurrar mudanças (commit/push) de dentro do Databricks pro GitHub, será exigido autenticação, é exatamente pra isso que o token serve.
Vamos colar esse token na Databricks agora

- Seu nome de perfil (lado esquerdo superior)
- Settings → Linked accounts
- Add Git credential
- Provider: GitHub
- Nickname: GitHub - databricks-lakehouse (ou outro)
- Authentication: Personal access token
- Cole o token que você gerou.


[imagem 04]

Resumo:
| Campo                     | Valor                                                                                            |
| ------------------------- | ------------------------------------------------------------------------------------------------ |
| **Git provider**          | GitHub                                                                                           |
| **Nickname**              | `GitHub - Databricks Lakehouse`                                                                  |
| **Git provider email**    | Seu e-mail do GitHub (o mesmo usado nos commits, se você quiser associar os commits à sua conta) |
| **Git provider username** | `seu_git_username`                                                                                      |
| **Token**                 | Cole o Fine-grained Personal Access Token                                                        |

---

3. Personal Access Token vs Link Git Account

**Por que usar um Personal Access Token?**
Embora o Databricks permita conectar a conta do GitHub via OAuth ("Link Git account"),
neste projeto utilizamos um Fine-grained Personal Access Token. Esse método permite
conceder apenas as permissões necessárias ao repositório, seguindo o princípio do menor privilégio,
além de ser amplamente compatível com ambientes corporativos.

**E o Link Git Account?**
Essa opção usa OAuth ("Entrar com GitHub"). É mais rápida e conveniente para uso pessoal, mas:

- a gente não controla as permissões com a mesma granularidade;
- a experiência pode variar conforme a versão do Databricks;
- em empresas, muitas vezes essa opção nem está disponível.

Como nosso objetivo é criar uma documentação didática e reproduzível, eu mantenho o fluxo com Personal Access Token.