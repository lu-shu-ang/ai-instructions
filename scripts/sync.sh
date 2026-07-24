#!/usr/bin/env bash
set -euo pipefail
PATH='/usr/bin:/bin:/usr/sbin:/sbin'

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

if ! git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a Git repository: $repo_root" >&2
  exit 1
fi

if git -C "$repo_root" remote get-url origin >/dev/null 2>&1; then
  git -C "$repo_root" fetch --quiet origin
  local_branch="$(git -C "$repo_root" branch --show-current)"
  upstream_ref="$(git -C "$repo_root" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"

  if [[ -z "$upstream_ref" ]]; then
    echo "Current branch has no upstream; skipping pull."
  elif [[ "$(git -C "$repo_root" rev-parse HEAD)" == "$(git -C "$repo_root" rev-parse "$upstream_ref")" ]]; then
    echo "Already current on ${local_branch}."
  elif [[ -n "$(git -C "$repo_root" status --porcelain)" ]]; then
    echo "Local changes exist; refusing to update the instructions checkout." >&2
    exit 1
  else
    git -C "$repo_root" merge --ff-only "$upstream_ref"
  fi
else
  echo "No origin remote configured; skipping pull."
fi

"$repo_root/scripts/install.sh"
