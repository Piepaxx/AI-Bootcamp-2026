#!/usr/bin/env bash
# SessionStart, PostToolUse (Write|Edit|MultiEdit), Stop: ține la zi docs/LEGENDA.md.
# După o modificare în .claude/skills/, .claude/hooks/, .claude/scripts/ sau .claude/settings.json
# rulează .claude/scripts/gen-legend.sh. La pornire și la Stop îl rulează oricum, ca să prindă
# și schimbările făcute de mână sau din terminal. Nu afișează nimic și nu blochează nimic.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
input=$(cat)

if printf '%s' "$input" | grep -q '"hook_event_name"[[:space:]]*:[[:space:]]*"PostToolUse"'; then
  path=$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | tr '\\' '/')
  printf '%s' "$path" | grep -Eq '\.claude/+(skills|hooks|scripts)/|\.claude/+settings\.json' || exit 0
fi

bash .claude/scripts/gen-legend.sh >/dev/null 2>&1
exit 0
