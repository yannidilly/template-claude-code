#!/usr/bin/env bash
# Hook PreToolUse do agente implementer (ver .claude/agents/implementer.md).
# Bloqueia Edit/Write/NotebookEdit em arquivos de teste já commitados.
# Arquivos de teste novos e edições por shell são pegos por tools/gate-tests.sh.
#
# Entrada: o JSON do hook no stdin. Sair com 2 bloqueia a ferramenta e mostra o stderr ao agente.

set -uo pipefail

# shellcheck source=tools/test-paths.sh
source "$(dirname "$0")/../test-paths.sh"

input="$(cat)"

# Extrai tool_input.file_path (ou notebook_path) sem depender do jq.
file_path="$(printf '%s' "$input" | sed -n 's/.*"\(file_path\|notebook_path\)"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\2/p' | head -n 1)"
[ -n "$file_path" ] || exit 0

root="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
case "$file_path" in
  "$root"/*) rel="${file_path#"$root"/}" ;;
  /*) exit 0 ;;
  *) rel="$file_path" ;;
esac

matches_test_glob() {
  local glob pattern
  while IFS= read -r glob; do
    # Converte o glob do git num padrão do bash: "**/" pode ser vazio e "/**" casa com o resto.
    pattern="${glob//\*\*\//*/}"
    pattern="${pattern//\/\*\*//*}"
    # shellcheck disable=SC2053
    if [[ "/$rel" == $pattern || "$rel" == $pattern ]]; then
      return 0
    fi
  done < <(read_test_paths)
  return 1
}

if matches_test_glob && git -C "$root" ls-files --error-unmatch -- "$rel" >/dev/null 2>&1; then
  echo "Bloqueado: $rel é um arquivo de teste protegido. O implementer nunca altera testes." >&2
  echo "Continue a implementação e registre uma pendência explicando por que o teste parece errado." >&2
  exit 2
fi

exit 0
