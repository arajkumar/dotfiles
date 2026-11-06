#!/usr/bin/env bash
set -euo pipefail

PI_CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command -v node >/dev/null
files=(
  agent/AGENTS.md
  agent/settings.json
  agent/models.json
  agent/mcp.json
  agent/extensions/guardrails.json
  agent/extensions/guardrails-classifier/index.ts
  agent/pi-warden/config.json
  agent/pi-warden/rules.md
  web-search.json
)

for file in "${files[@]}"; do
  source="$PI_CONFIG/$file"
  target="$HOME/.pi/$file"
  [[ -f "$source" ]]
  if [[ "$file" == agent/pi-warden/config.json ]]; then
    content="$(node - "$source" <<'JS'
const { readFileSync } = require("node:fs");
const config = JSON.parse(readFileSync(process.argv[2], "utf8"));
config.rules.files = config.rules.files.map(path => path.replace(/^\$HOME(?=\/|$)/, () => process.env.HOME));
process.stdout.write(JSON.stringify(config, null, 2));
JS
)"
    if [[ -f "$target" && ! -L "$target" && "$(<"$target")" == "$content" ]]; then
      continue
    fi
  elif [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    continue
  fi
  mkdir -p "$(dirname "$target")"
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    rm "$target"
  elif [[ -e "$target" || -L "$target" ]]; then
    if [[ -e "$target.bak" || -L "$target.bak" ]]; then
      printf 'Backup exists: %s.bak\n' "$target" >&2
      exit 1
    fi
    mv "$target" "$target.bak"
  fi
  if [[ "$file" == agent/pi-warden/config.json ]]; then
    (umask 077; printf '%s\n' "$content" > "$target")
  else
    ln -s "$source" "$target"
  fi
done

printf 'Pi config installed.\n'
