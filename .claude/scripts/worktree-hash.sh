#!/usr/bin/env bash
# Amprenta modificărilor necommise, FĂRĂ docs/LOG.md și docs/LEGENDA.md (generată automat).
# Hook-urile o compară între începutul sesiunii și Stop ca să știe dacă s-a lucrat ceva.
{
  git diff HEAD -- . ':(exclude)docs/LOG.md' ':(exclude)docs/LEGENDA.md' 2>/dev/null
  git ls-files -o --exclude-standard 2>/dev/null | grep -v -e '^docs/LOG.md$' -e '^docs/LEGENDA.md$' | while IFS= read -r f; do
    echo "$f $(git hash-object "$f" 2>/dev/null)"
  done
} | git hash-object --stdin
