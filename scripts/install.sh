#!/usr/bin/env bash
set -euo pipefail

force=false
if [[ "${1:-}" == "--force" ]]; then
  force=true
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--force]" >&2
  exit 2
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
timestamp="$(date +%Y%m%d-%H%M%S)"

install_entry() {
  local target="$1"
  local tool_extra="$2"
  local parent
  parent="$(dirname "$target")"
  mkdir -p "$parent"

  if [[ -e "$target" ]] && ! rg -Fq "Managed by ai-instructions" "$target"; then
    if [[ "$force" != true ]]; then
      echo "Refusing to replace existing unmanaged file: $target" >&2
      echo "Review it, then rerun with --force to create a backup and replace it." >&2
      return 1
    fi
    mv "$target" "${target}.${timestamp}.bak"
    echo "Backed up $target to ${target}.${timestamp}.bak"
  fi

  cat > "$target" <<EOF
# Managed by ai-instructions — do not edit this generated entry directly.
# Shared rules are versioned in the repository below.

Read and follow this shared policy in full:
${repo_root}/common/POLICY.md

Then read and follow this tool-specific supplement in full:
${repo_root}/${tool_extra}

If a project contains more specific instructions, follow them as well. When rules conflict, use the more specific applicable rule unless it weakens safety requirements.
EOF
  echo "Installed $target"
}

install_entry "$HOME/.codex/AGENTS.md" "codex/EXTRA.md"
install_entry "$HOME/.claude/CLAUDE.md" "claude/EXTRA.md"

