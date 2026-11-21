#!/usr/bin/env bash
# Afișează numele celui care lucrează, pentru LOG.md.
# Ordinea: LOG_AUTHOR (din .claude/settings.local.json) > git user.name > utilizatorul OS.
if [ -n "$LOG_AUTHOR" ]; then
  echo "$LOG_AUTHOR"
  exit 0
fi
name=$(git config user.name 2>/dev/null)
if [ -n "$name" ]; then
  echo "$name"
  exit 0
fi
echo "${USER:-${USERNAME:-necunoscut}}"
