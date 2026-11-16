#!/usr/bin/env bash
# Imprime os globs de teste protegidos de tools/test-paths.txt, um por linha,
# sem comentários nem linhas em branco. Carregado pelo gate e pelo hook.

test_paths_file="$(dirname "${BASH_SOURCE[0]}")/test-paths.txt"

read_test_paths() {
  [ -f "$test_paths_file" ] || return 0
  sed -e 's/[[:space:]]*#.*$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$test_paths_file" | grep -v '^$' || true
}
