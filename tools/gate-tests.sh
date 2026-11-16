#!/usr/bin/env bash
# Gate de proteção dos testes.
# Falha se qualquer arquivo de teste difere do commit que congelou os testes.
#
# Uso: tools/gate-tests.sh <tests_commit>
#
# Os globs protegidos vêm de tools/test-paths.txt (fonte única).

set -euo pipefail

# shellcheck source=tools/test-paths.sh
source "$(dirname "$0")/test-paths.sh"

base="${1:?Informe o SHA de tests_commit (campo do frontmatter da spec).}"

if ! git cat-file -e "${base}^{commit}" 2>/dev/null; then
  echo "GATE REPROVADO: o commit ${base} não existe neste repositório."
  exit 2
fi

paths=()
while IFS= read -r glob; do
  paths+=(":(glob)${glob}")
done < <(read_test_paths)

if [ "${#paths[@]}" -eq 0 ]; then
  echo "GATE REPROVADO: tools/test-paths.txt não tem nenhum glob. Rode /project-init."
  exit 2
fi

# Arquivos de teste alterados, apagados ou renomeados (árvore de trabalho x commit dos testes).
changed="$(git diff --name-status "$base" -- "${paths[@]}")"

# Arquivos de teste novos ainda não versionados.
untracked="$(git ls-files --others --exclude-standard -- "${paths[@]}")"

if [ -n "$changed" ] || [ -n "$untracked" ]; then
  echo "GATE REPROVADO: os arquivos de teste diferem de ${base}."
  if [ -n "$changed" ]; then
    echo "Alterados:"
    echo "$changed"
  fi
  if [ -n "$untracked" ]; then
    echo "Novos (não versionados):"
    echo "$untracked"
  fi
  exit 1
fi

echo "GATE OK: nenhum arquivo de teste difere de ${base}."
