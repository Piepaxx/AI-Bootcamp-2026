#!/usr/bin/env bash
# Afișează titlul unei intrări noi din LOG.md: data, ora, autorul și (opțional) sesiunea.
# Folosire: bash .claude/scripts/log-header.sh [id-sesiune]
dir="$(cd "$(dirname "$0")" && pwd)"
author=$(bash "$dir/whoami.sh")
line="## $(date '+%Y-%m-%d %H:%M') · $author"
if [ -n "$1" ]; then
  line="$line · sesiune ${1:0:8}"
fi
echo "$line"
