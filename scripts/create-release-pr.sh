gh pr create --repo RegiMaria/databricks-lakehouse \
  --base main \
  --head develop \
  --title "release: promove develop para main" \
  --body "## Resumo

Promove as alterações validadas na branch develop para a branch principal.

## Alterações incluídas

- Guia de integração GitHub x Databricks
- Documentação de autenticação Git via PAT e OAuth
- Organização dos tutoriais

## Checklist

- [x] Alterações revisadas em develop
- [x] PR anterior mergeada
- [x] Documentação validada
- [x] Sem dados sensíveis commitados"