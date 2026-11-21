#!/usr/bin/env bash
# Regenerează docs/LEGENDA.md din: .claude/settings.json (hook-uri, plugin-uri),
# comentariul de antet al scripturilor din .claude/hooks/ și .claude/scripts/,
# și frontmatter-ul (name, description) din .claude/skills/*/SKILL.md.
# Scrie fișierul doar dacă s-a schimbat ceva. Folosire: bash .claude/scripts/gen-legend.sh
root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$root" || exit 0
out="docs/LEGENDA.md"
tmp="$(mktemp)"
tsv="$(mktemp)"
trap 'rm -f "$tmp" "$tsv"' EXIT

# Liniile de comentariu de după shebang, până la primul rând de cod.
header_comment() {
  awk 'NR==1 && /^#!/ {next} /^#/ {sub(/^# ?/, ""); print; next} {exit}' "$1"
}

# Antetul unui hook, fără prefixul „Eveniment (matcher): ” (e deja în legendă).
hook_description() {
  header_comment "$1" | awk 'NR==1 {sub(/^[A-Z][A-Za-z]*(, *[A-Z][A-Za-z]*( *\([^)]*\))?)*( *\([^)]*\))?: */, "")} {print}'
}

event_ro() {
  case "$1" in
    SessionStart)     echo "la pornirea sesiunii (și după /clear, /compact)" ;;
    SessionEnd)       echo "la închiderea sesiunii" ;;
    UserPromptSubmit) echo "când trimiți un mesaj, înainte să-l citească Claude" ;;
    PreToolUse)       echo "înainte ca Claude să folosească un tool" ;;
    PostToolUse)      echo "după ce Claude a folosit un tool" ;;
    Stop)             echo "când Claude termină de răspuns" ;;
    SubagentStop)     echo "când un subagent termină" ;;
    PreCompact)       echo "înainte de comprimarea conversației" ;;
    Notification)     echo "când Claude trimite o notificare" ;;
    *)                echo "$1" ;;
  esac
}

md_cell() { tr '\n' ' ' | sed 's/|/\\|/g; s/[[:space:]]*$//'; }

# --- settings.json -> TSV: HOOK<TAB>eveniment<TAB>matcher<TAB>timeout<TAB>comandă | PLUGIN<TAB>nume
# Câmpurile goale devin „-”, altfel `read` comprimă tab-urile consecutive și decalează coloanele.
if [ -f .claude/settings.json ]; then
  awk '
    function val(line, s) { s = line; sub(/^[^:]*:[ \t]*"/, "", s); sub(/"[ \t]*,?[ \t]*$/, "", s); gsub(/\\"/, "\"", s); return s }
    /^[ \t]*"enabledPlugins"[ \t]*:[ \t]*\{/ { inpl = 1; next }
    inpl && /\}/ { inpl = 0; next }
    inpl {
      if (match($0, /"[^"]+"[ \t]*:[ \t]*true/)) { s = substr($0, RSTART + 1); sub(/".*/, "", s); print "PLUGIN\t" s }
      next
    }
    /^[ \t]*"[A-Z][A-Za-z]*"[ \t]*:[ \t]*\[/ { ev = $0; sub(/^[ \t]*"/, "", ev); sub(/".*/, "", ev); m = ""; next }
    ev != "" && /"matcher"[ \t]*:/ { m = val($0); next }
    ev != "" && /"hooks"[ \t]*:[ \t]*\[/ { cur = m; m = ""; next }
    ev != "" && /"command"[ \t]*:/ { cmd = val($0); next }
    ev != "" && /"timeout"[ \t]*:/ { to = $0; gsub(/[^0-9]/, "", to); next }
    # Câmpurile goale devin „-”, altfel `read` comprimă tab-urile consecutive și decalează coloanele.
    ev != "" && /^[ \t]*\}/ && cmd != "" { print "HOOK\t" ev "\t" (cur == "" ? "-" : cur) "\t" (to == "" ? "-" : to) "\t" cmd; cmd = ""; to = "" }
  ' .claude/settings.json > "$tsv"
fi

{
  echo "# LEGENDA: hook-uri și skill-uri"
  echo
  echo "> **Generat automat** de \`.claude/scripts/gen-legend.sh\`. Nu-l edita de mână: se rescrie."
  echo "> Ca să schimbi un text de aici, modifică **comentariul de la începutul scriptului** (hook-uri) sau **\`description\` din SKILL.md** (skill-uri)."
  echo "> Se reface singur când Claude modifică ceva în \`.claude/\`, la fiecare pornire de sesiune și la fiecare final de răspuns."
  echo

  # ---------------- Hook-uri
  echo "## Hook-uri"
  echo
  echo "Rulează automat, nu le pornește nimeni de mână. Sunt înregistrate în \`.claude/settings.json\` (comune, în git)."
  echo
  scripts=$(awk -F '\t' '$1 == "HOOK"' "$tsv" | grep -o '\.claude/hooks/[A-Za-z0-9._-]*' | sed 's#.*/##' | awk '!seen[$0]++')
  if [ -z "$scripts" ]; then
    echo "_Niciun hook înregistrat._"
    echo
  fi
  for s in $scripts; do
    echo "### \`$s\`"
    echo
    awk -F '\t' -v s="/$s" '$1 == "HOOK" && index($5, s)' "$tsv" | while IFS="$(printf '\t')" read -r _ ev matcher to _; do
      [ "$matcher" = "-" ] && matcher=""
      [ "$to" = "-" ] && to=""
      line="- **Când:** $(event_ro "$ev") (\`$ev\`)"
      [ -n "$matcher" ] && line="$line · **pe:** \`$matcher\`"
      [ -n "$to" ] && line="$line · **timp maxim:** ${to} s"
      echo "$line"
    done
    echo
    if [ -f ".claude/hooks/$s" ]; then
      desc=$(hook_description ".claude/hooks/$s")
      if [ -n "$desc" ]; then echo "$desc"; else echo "_Fără descriere: adaugă un comentariu la începutul scriptului._"; fi
    else
      echo "**ATENȚIE:** scriptul \`.claude/hooks/$s\` lipsește, dar e înregistrat în settings.json."
    fi
    echo
  done

  inline=$(awk -F '\t' '$1 == "HOOK" && $5 !~ /\.claude\/hooks\//' "$tsv")
  if [ -n "$inline" ]; then
    echo "### Comenzi scrise direct în settings.json"
    echo
    printf '%s\n' "$inline" | while IFS="$(printf '\t')" read -r _ ev matcher _ cmd; do
      echo "- $(event_ro "$ev") (\`$ev\`${matcher:+, pe \`$matcher\`}): \`$cmd\`"
    done
    echo
  fi

  orphans=""
  for f in .claude/hooks/*.sh; do
    [ -f "$f" ] || continue
    b=$(basename "$f")
    printf '%s\n' "$scripts" | grep -qx "$b" || orphans="$orphans $b"
  done
  if [ -n "$orphans" ]; then
    echo "### Scripturi neînregistrate (nu rulează)"
    echo
    for b in $orphans; do
      echo "- \`$b\`: $(header_comment ".claude/hooks/$b" | head -1)"
    done
    echo
  fi

  # ---------------- Skill-uri
  echo "## Skill-uri"
  echo
  echo "Rețete pe care Claude le încarcă singur când se potrivesc cu sarcina, sau pe care le pornești tu cu \`/nume\`."
  echo
  echo "| Skill | Cine îl pornește | Origine | Ce face |"
  echo "|---|---|---|---|"
  for f in .claude/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    row=$(awk '
      NR == 1 && /^---/ { f = 1; next }
      f && /^---/ { exit }
      f {
        if ($0 ~ /^[A-Za-z][A-Za-z0-9_-]*:/) { k = $0; sub(/:.*/, "", k); v = $0; sub(/^[^:]*:[ \t]*/, "", v); cur = k; val[k] = v; next }
        if (cur != "" && $0 ~ /^[ \t]+/) { v = $0; sub(/^[ \t]+/, "", v); val[cur] = val[cur] " " v }
      }
      END {
        d = val["description"]; sub(/^[>|][-+]?[ \t]*/, "", d); sub(/^[ \t]+/, "", d)
        if (d ~ /^".*"$/ || d ~ /^\047.*\047$/) d = substr(d, 2, length(d) - 2)
        print val["name"] "\t" d "\t" val["disable-model-invocation"] "\t" val["user-invocable"]
      }' "$f")
    name=$(printf '%s' "$row" | cut -f1)
    [ -z "$name" ] && name=$(basename "$(dirname "$f")")
    desc=$(printf '%s' "$row" | cut -f2 | md_cell)
    dmi=$(printf '%s' "$row" | cut -f3)
    ui=$(printf '%s' "$row" | cut -f4)
    if [ "$dmi" = "true" ]; then who="doar tu: \`/$name\`"
    elif [ "$ui" = "false" ]; then who="doar Claude, automat"
    else who="tu (\`/$name\`) sau Claude, automat"; fi
    origin="echipă"
    if [ -f .claude/skills/THIRD_PARTY.md ] && grep -q "^| \`$name\` |" .claude/skills/THIRD_PARTY.md; then
      origin="extern ([THIRD_PARTY](../.claude/skills/THIRD_PARTY.md))"
    fi
    [ -z "$desc" ] && desc="_Fără descriere: completează \`description\` în SKILL.md._"
    echo "| [\`$name\`](../$f) | $who | $origin | $desc |"
  done
  echo

  # ---------------- Plugin-uri
  plugins=$(awk -F '\t' '$1 == "PLUGIN" {print $2}' "$tsv")
  if [ -n "$plugins" ]; then
    echo "## Plugin-uri activate pentru proiect"
    echo
    for p in $plugins; do echo "- \`$p\`"; done
    echo
  fi

  # ---------------- Scripturi ajutătoare
  echo "## Scripturi ajutătoare (\`.claude/scripts/\`)"
  echo
  echo "Nu rulează singure: le apelează hook-urile, skill-urile sau Claude."
  echo
  for f in .claude/scripts/*.sh; do
    [ -f "$f" ] || continue
    echo "- \`$(basename "$f")\`: $(header_comment "$f" | md_cell)"
  done
  echo
  echo "## Hook-uri personale"
  echo
  echo "Hook-urile din \`.claude/settings.local.json\` sunt ale fiecăruia, nu intră în git și nu apar aici."
} > "$tmp"

mkdir -p docs
if [ ! -f "$out" ] || ! cmp -s "$tmp" "$out"; then
  cp "$tmp" "$out"
  echo "docs/LEGENDA.md actualizat"
fi
exit 0
