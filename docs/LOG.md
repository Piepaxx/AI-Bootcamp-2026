# LOG: jurnalul echipei

Ce s-a făcut, ce s-a decis, ce a rămas. Fiecare sesiune de lucru (din orice cont de Claude) adaugă **o intrare**, cu ora și autorul. Formatul e în `CLAUDE.md`, secțiunea Jurnal.

- Cele mai noi intrări sunt **primele**, imediat sub linia marcaj.
- Titlul se generează cu `bash .claude/scripts/log-header.sh`.
- La merge, git combină automat intrările tuturor (`merge=union` în `.gitattributes`). Nu șterge intrările altora.

<!-- INTRĂRI NOI AICI: cele mai noi primele -->

## 2026-11-21 09:40 · Stefanita
**Rol:** organizare echipă (unelte Claude Code)
**Ce am făcut:**
- `docs/LEGENDA.md`: legenda generată automat cu toate hook-urile (când rulează, pe ce, ce fac), skill-urile (cine le pornește, origine, ce fac), plugin-urile și scripturile ajutătoare.
- Generatorul `.claude/scripts/gen-legend.sh` citește `settings.json`, comentariul de antet al scripturilor și `description` din fiecare `SKILL.md`. Scrie fișierul doar dacă s-a schimbat ceva.
- Hook-ul `legend-update.sh` rulează generatorul în trei momente:
  - la SessionStart;
  - la PostToolUse, doar când se modifică ceva în `.claude/skills|hooks|scripts` sau în `settings.json`;
  - la Stop.
- Legenda e exclusă din amprenta hook-ului de jurnal și are `merge=union` în `.gitattributes`.
- Convenția pentru hook-uri și skill-uri noi e trecută în `CLAUDE.md`. `/finish` regenerează legenda înainte de commit.

**Decizii:**
- Legenda e fișier generat, nu se editează de mână. Textele vin din antetul scripturilor și din `description`.

**Ce a rămas:**
- [ ] Opțional: antetul din `kotlin-ui-check.sh` începe cu „PostToolUse (...) pe fișiere .kt” fără „:” după paranteză, așa că prefixul rămâne în legendă. E doar cosmetic.

**Fișiere:** `.claude/scripts/gen-legend.sh`, `.claude/hooks/legend-update.sh`, `.claude/settings.json`, `.claude/scripts/worktree-hash.sh`, `.claude/skills/finish/SKILL.md`, `.gitattributes`, `CLAUDE.md`, `docs/ARCHITECTURE.md`, `docs/LEGENDA.md`

## 2026-11-21 09:35 · Stefanita · sesiune e0c3248a
**Rol:** organizare echipă (unelte Claude Code)
**Ce am făcut:**
- 9 skill-uri externe pentru Android/Compose, verificate de un agent de securitate (read-only), copiate în `.claude/skills/`: `edge-to-edge`, `jetpack-compose-performance`, `android-intent-security`, `testing-setup` (Google), `compose-animations`, `compose-component-design`, `compose-state-and-effects`, `kotlin-concurrency-and-flow` (Chris Banes), `material-3-expressive`. Sursele, commit-urile și licențele sunt în `.claude/skills/THIRD_PARTY.md`.
- Skill nou al echipei: `coridor-ui` (principiile din `CONTEXT.md` §10 + ce skill folosești pentru ce + lista de verificare pe ecran).
- Hook-uri noi:
  - `guard-secrets.sh` (PreToolUse): blochează cheia Anthropic în afara `.env` și cheia Supabase service_role în `android/` sau `admin-web/`;
  - `kotlin-ui-check.sh` (PostToolUse): rulează ktlint dacă e instalat și semnalează culorile și fonturile scrise direct în locul temei M3.
- Plugin activat pentru proiect: `supabase@claude-plugins-official` (skill-uri Supabase + MCP oficial).
- Repo conectat la GitHub: `origin` = github.com/stefanitapopescu/AI-Bootcamp-2026 (**public**, confirmat de Stefanita), primul commit + push pe `main`.

**Decizii:**
- Skill-urile externe intră în repo doar după audit, cu commit-ul notat. Plugin-ul Supabase MCP se conectează la proiectul de dev.

**Ce a rămas:**
- [ ] Opțional, fiecare pe mașina lui: `kotlin-lsp` / `pyright` + plugin-urile `kotlin-lsp`, `pyright-lsp` (nu sunt activate în proiect, ca să nu dea erori celor fără binar).
- [ ] Când apare `android/`: verificat pe cod real că `kotlin-ui-check` nu dă prea multe alarme false.

**Fișiere:** `.claude/settings.json`, `.claude/hooks/guard-secrets.sh`, `.claude/hooks/kotlin-ui-check.sh`, `.claude/skills/*`, `docs/ARCHITECTURE.md`

## 2026-11-21 09:27 · Stefanita
**Rol:** organizare echipă
**Ce am făcut:**
- Am creat structura de lucru în echipă: `CLAUDE.md`, `docs/LOG.md`, `docs/ARCHITECTURE.md`.
- Hook-uri comune în `.claude/settings.json`:
  - SessionStart: arată autorul, ora, starea față de GitHub și ultimele 3 intrări din jurnal;
  - Stop: cere intrarea în jurnal dacă s-au modificat fișiere, o dată pe sesiune.
- Skill-uri: `/start`, `/log`, `/finish`.
- `.gitattributes` (`docs/LOG.md merge=union`, `*.sh` cu LF) și `.gitignore`.
- `git init` în folderul proiectului.

**Decizii:**
- Memoria comună e repo-ul git: conturile de Claude nu își văd conversațiile.
- O intrare pe sesiune, cele mai noi primele. Autorul vine din `LOG_AUTHOR` sau `git config user.name`.

**Ce a rămas:**
- [ ] Repo pe GitHub (privat) + colegii adăugați drept colaboratori; primul commit + push.
- [ ] Fiecare coleg: `git clone`, apoi `.claude/settings.local.json` cu `LOG_AUTHOR` (vezi `docs/ARCHITECTURE.md`, Primii pași).
- [ ] De confirmat dacă fișierele de date din rădăcină se mută în `data/` (atunci se actualizează `CONTEXT.md` §17).

**Fișiere:** `CLAUDE.md`, `docs/LOG.md`, `docs/ARCHITECTURE.md`, `.claude/settings.json`, `.claude/hooks/*`, `.claude/scripts/*`, `.claude/skills/*`, `.gitattributes`, `.gitignore`
