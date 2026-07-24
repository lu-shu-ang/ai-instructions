#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

if ! git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a Git repository: $repo_root" >&2
  exit 1
fi

if git -C "$repo_root" remote get-url origin >/dev/null 2>&1; then
  git -C "$repo_root" pull --ff-only
else
  echo "No origin remote configured; skipping pull."
fi

"$repo_root/scripts/install.sh"

