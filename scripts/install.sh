#!/usr/bin/env bash
set -euo pipefail
PATH='/usr/bin:/bin:/usr/sbin:/sbin'

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
  local tool_name="$2"
  local tool_extra="$3"
  local parent
  parent="$(dirname "$target")"
  mkdir -p "$parent"

  if [[ -e "$target" ]] && ! grep -Fq "Managed by ai-instructions" "$target"; then
    if [[ "$force" != true ]]; then
      echo "Refusing to replace existing unmanaged file: $target" >&2
      echo "Review it, then rerun with --force to create a backup and replace it." >&2
      return 1
    fi
    mv "$target" "${target}.${timestamp}.bak"
    echo "Backed up $target to ${target}.${timestamp}.bak"
  fi

  {
    printf '%s\n\n' '# Managed by ai-instructions — do not edit this generated entry directly.'
    printf '%s\n\n' "# Source repository: ${repo_root}"
    printf '%s\n\n' "# Generated at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '%s\n\n' "# ${tool_name} global instructions"
    printf '%s\n\n' '<!-- BEGIN SHARED POLICY -->'
    sed '/^# /s/^# /# Shared: /' "$repo_root/common/POLICY.md"
    printf '%s\n\n' '<!-- END SHARED POLICY -->'
    printf '%s\n\n' '<!-- BEGIN TOOL SUPPLEMENT -->'
    sed '/^# /s/^# /# Tool-specific: /' "$repo_root/$tool_extra"
    printf '%s\n\n' '<!-- END TOOL SUPPLEMENT -->'
    printf '%s\n' 'If a project contains more specific instructions, follow them as well. When rules conflict, use the more specific applicable rule unless it weakens safety requirements.'
  } > "$target"
  echo "Installed $target"
}

install_entry "$HOME/.codex/AGENTS.md" "Codex" "codex/EXTRA.md"
install_entry "$HOME/.claude/CLAUDE.md" "Claude Code" "claude/EXTRA.md"
