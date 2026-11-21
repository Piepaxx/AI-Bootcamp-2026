#!/usr/bin/env bash
# SessionStart: îi spune lui Claude cine lucrează, dacă repo-ul e la zi cu GitHub
# și ce au făcut colegii recent (primele intrări din docs/LOG.md).
# Tot ce se scrie pe stdout ajunge în contextul lui Claude.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
input=$(cat)
session_id=$(printf '%s' "$input" | grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
author=$(bash .claude/scripts/whoami.sh)

echo "=== Sesiune de lucru în echipă (din .claude/hooks/session-start.sh) ==="
echo "Autor: $author | Acum: $(date '+%Y-%m-%d %H:%M') | Sesiune: ${session_id:0:8}"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Amprenta de început, folosită de hook-ul Stop. Nu se rescrie la /compact.
  if [ -n "$session_id" ]; then
    mkdir -p .claude/.state
    snap=".claude/.state/start-$session_id"
    if [ ! -f "$snap" ]; then
      {
        bash .claude/scripts/worktree-hash.sh
        git hash-object docs/LOG.md 2>/dev/null || echo "fara-log"
      } > "$snap"
    fi
  fi

  branch=$(git branch --show-current 2>/dev/null)
  echo "Ramura: ${branch:-?}"
  if [ -n "$(git remote)" ]; then
    if command -v timeout >/dev/null 2>&1; then
      GIT_TERMINAL_PROMPT=0 timeout 8 git fetch --quiet >/dev/null 2>&1
    else
      GIT_TERMINAL_PROMPT=0 git fetch --quiet >/dev/null 2>&1
    fi
    behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)
    ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
    if [ -n "$behind" ] && [ "$behind" -gt 0 ]; then
      echo "ATENȚIE: ești în urmă cu $behind commit-uri față de GitHub. Propune-i utilizatorului 'git pull --rebase' ÎNAINTE de orice modificare."
    fi
    if [ -n "$ahead" ] && [ "$ahead" -gt 0 ]; then
      echo "Ai $ahead commit-uri netrimise (push) din sesiuni anterioare."
    fi
  else
    echo "Repo-ul nu are încă remote (GitHub). Munca nu ajunge la colegi până nu se adaugă unul."
  fi
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  [ "$dirty" -gt 0 ] && echo "Fișiere modificate necommise: $dirty"
fi

if [ -f docs/LOG.md ]; then
  echo
  echo "--- Ultimele 3 intrări din docs/LOG.md (cele mai noi primele) ---"
  awk '/^## /{n++} n>=1 && n<=3' docs/LOG.md
  echo "--- sfârșit LOG ---"
fi
echo
echo "Regulă: la final de bucată de lucru, adaugă o intrare în docs/LOG.md (skill-ul /log). Pentru titlu rulează: bash .claude/scripts/log-header.sh ${session_id:0:8}"
exit 0
