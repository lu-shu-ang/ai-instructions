#!/usr/bin/env bash
set -euo pipefail
PATH='/usr/bin:/bin:/usr/sbin:/sbin'

if [[ "${1:-}" == "--uninstall" ]]; then
  uid="$(id -u)"
  plist="$HOME/Library/LaunchAgents/com.lu-shu-ang.ai-instructions-sync.plist"
  launchctl bootout "gui/${uid}" "$plist" 2>/dev/null || true
  echo "Stopped automatic sync. The plist remains at: $plist"
  exit 0
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--uninstall]" >&2
  exit 2
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
sync_script="$repo_root/scripts/sync.sh"
plist_dir="$HOME/Library/LaunchAgents"
plist="$plist_dir/com.lu-shu-ang.ai-instructions-sync.plist"
uid="$(id -u)"

if [[ ! -x "$sync_script" ]]; then
  echo "Sync script is not executable: $sync_script" >&2
  exit 1
fi

mkdir -p "$plist_dir"
cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.lu-shu-ang.ai-instructions-sync</string>
  <key>ProgramArguments</key>
  <array>
    <string>${sync_script}</string>
  </array>
  <key>StartInterval</key>
  <integer>60</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/ai-instructions-sync.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/ai-instructions-sync.log</string>
</dict>
</plist>
EOF

launchctl bootout "gui/${uid}" "$plist" 2>/dev/null || true
launchctl bootstrap "gui/${uid}" "$plist"
launchctl kickstart -k "gui/${uid}/com.lu-shu-ang.ai-instructions-sync"

echo "Automatic sync installed: every 60 seconds and at login."
echo "Log: /tmp/ai-instructions-sync.log"
