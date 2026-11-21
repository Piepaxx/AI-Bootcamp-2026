#!/usr/bin/env bash
# Stop: dacă în sesiunea asta s-au modificat fișiere, dar docs/LOG.md nu,
# îl oprește pe Claude O SINGURĂ DATĂ pe sesiune și îi cere să scrie intrarea în jurnal.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
input=$(cat)

# Evită bucla: Claude e deja în continuarea cerută de acest hook.
printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

session_id=$(printf '%s' "$input" | grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
[ -z "$session_id" ] && exit 0
snap=".claude/.state/start-$session_id"
flag=".claude/.state/reminded-$session_id"
[ -f "$snap" ] || exit 0
[ -f "$flag" ] && exit 0

start_work=$(sed -n 1p "$snap")
start_log=$(sed -n 2p "$snap")
now_work=$(bash .claude/scripts/worktree-hash.sh)
now_log=$(git hash-object docs/LOG.md 2>/dev/null || echo "fara-log")

if [ "$start_work" != "$now_work" ] && [ "$start_log" = "$now_log" ]; then
  touch "$flag"
  header=$(bash .claude/scripts/log-header.sh "$session_id")
  cat <<EOF
{"decision":"block","reason":"Ai modificat fișiere în această sesiune, dar docs/LOG.md nu are încă o intrare. Adaug-o acum după formatul din CLAUDE.md (secțiunea Jurnal), cu titlul: $header . Pune-o imediat sub linia marcaj din LOG.md (cele mai noi primele). Dacă lucrul nu e gata, notează asta la 'Ce a rămas'. Apoi spune-i utilizatorului pe scurt ce ai scris și că poate rula /finish pentru commit + push."}
EOF
fi
exit 0
