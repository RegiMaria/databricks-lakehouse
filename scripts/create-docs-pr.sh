gh pr create --repo RegiMaria/databricks-lakehouse \
  --base develop \
  --head docs/git-credential-comparison \
  --title "docs: guia de integração GitHub x Databricks (PAT, credenciais, imagens)" \
  --body "## Resumo

Finaliza a documentação de integração entre GitHub e Databricks, cobrindo geração de token e configuração da credencial Git no workspace.

## O que foi feito

- Documenta a comparação entre **Personal Access Token (fine-grained)** vs **Link Git Account (OAuth)** como formas de autenticar o Git folder no Databricks
- Adiciona imagens de referência ilustrando os passos de configuração
- Ajustes de formatação, indentação e correções de texto no guia
- Atualização do passo 4 e do resumo do escopo mínimo de permissões
- Pequenos ajustes no .gitignore

## Como revisar

- [ ] Ler docs/03_databricks_add_git_credential.md do início ao fim
- [ ] Conferir se as imagens renderizam corretamente no GitHub
- [ ] Verificar se os passos batem com o fluxo real testado (PAT + Git credential no Databricks)

## Checklist

- [x] Documentação revisada
- [x] Nenhum token/segredo real commitado (só exemplos)
- [x] Imagens adicionadas e linkadas corretamente"