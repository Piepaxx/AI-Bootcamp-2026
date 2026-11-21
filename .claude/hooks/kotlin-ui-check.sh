#!/usr/bin/env bash
# PostToolUse (Write|Edit|MultiEdit) pe fișiere .kt din android/:
# 1. dacă ktlint e instalat, formatează fișierul (altfel nu face nimic);
# 2. semnalează culori și mărimi de font scrise direct în ecrane, în loc de tema
#    Material 3 (MaterialTheme.colorScheme / typography), ca UI-ul să rămână unitar.
# Nu blochează nimic: îi trimite lui Claude o observație pe care o poate corecta.
input=$(cat)

file=$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
  | sed 's/.*"\([^"]*\)"$/\1/' | tr '\\' '/' | sed 's#//*#/#g')
case "$file" in
  *android/*.kt) ;;
  *) exit 0 ;;
esac
[ -f "$file" ] || exit 0

if command -v ktlint >/dev/null 2>&1; then
  ktlint -F --relative "$file" >/dev/null 2>&1
fi

# Fișierele temei au voie să definească culori și fonturi.
case "$file" in
  */ui/theme/*|*/designsystem/*|*Theme.kt|*Color.kt|*Type.kt) exit 0 ;;
esac

colors=$(grep -nE 'Color\(0x[0-9A-Fa-f]{6,8}\)|Color\.(Red|Green|Blue|Black|White|Gray|Yellow|Cyan|Magenta|DarkGray|LightGray)\b' "$file" | head -5 | cut -c1-120)
fonts=$(grep -nE 'fontSize[[:space:]]*=[[:space:]]*[0-9.]+\.sp' "$file" | head -5 | cut -c1-120)
[ -z "$colors$fonts" ] && exit 0

msg="kotlin-ui-check: în $(basename "$file") sunt valori scrise direct în loc de tema Material 3."
[ -n "$colors" ] && msg="$msg Culori (folosește MaterialTheme.colorScheme.*, mod întunecat inclus): $(printf '%s' "$colors" | tr '\n' ';')"
[ -n "$fonts" ] && msg="$msg Fonturi (folosește MaterialTheme.typography.*): $(printf '%s' "$fonts" | tr '\n' ';')"
msg="$msg Dacă e intenționat (ex. culoarea unui pin pe hartă), mut-o în ui/theme/ ca token."

# Escapare minimă pentru JSON.
msg=$(printf '%s' "$msg" | tr '\\\t' '/ ' | sed 's/"/\\"/g')
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$msg"
exit 0
