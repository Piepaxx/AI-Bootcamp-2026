#!/usr/bin/env bash
# PreToolUse (Write|Edit|MultiEdit): blochează scrierea de chei secrete în cod.
# - cheia Anthropic (sk-ant-...) nicăieri în afară de fișiere .env
# - cheia Supabase service_role / sb_secret_ nicăieri în android/ sau admin-web/
#   (codul de client e public: oricine dezarhivează APK-ul vede cheia)
input=$(cat)

file=$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
  | sed 's/.*"\([^"]*\)"$/\1/' | tr '\\' '/' | sed 's#//*#/#g')
[ -z "$file" ] && exit 0

case "$file" in
  *.env|*/.env.*|*.env.example) exit 0 ;;
esac

if printf '%s' "$input" | grep -Eq 'sk-ant-(api|admin)[0-9]*-[A-Za-z0-9_-]{20,}'; then
  echo "Blocat de guard-secrets: textul conține o cheie Anthropic (sk-ant-...). Pune cheia în backend/.env (ignorat de git) și citește-o cu os.environ, nu o scrie în cod." >&2
  exit 2
fi

case "$file" in
  */android/*|*/admin-web/*|android/*|admin-web/*)
    if printf '%s' "$input" | grep -Eqi 'service_role|sb_secret_[A-Za-z0-9_-]{10,}'; then
      echo "Blocat de guard-secrets: cheia Supabase service_role/secret nu are voie în android/ sau admin-web/ (codul de client e public). Folosește cheia publică (anon/publishable) + RLS; operațiile de admin trec prin backend/." >&2
      exit 2
    fi
    ;;
esac
exit 0
