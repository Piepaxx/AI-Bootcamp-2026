---
name: finish
description: Închide o sesiune de lucru - scrie intrarea în docs/LOG.md, apoi commit, pull --rebase și push, ca munca să ajungă la colegi.
disable-model-invocation: true
---

# /finish: predă lucrul echipei

1. **Jurnal.** Urmează pașii din skill-ul `/log` (`.claude/skills/log/SKILL.md`). Intrarea trebuie să existe înainte de commit.
2. **Verifică ce intră în commit.** Rulează întâi `bash .claude/scripts/gen-legend.sh`, ca `docs/LEGENDA.md` să fie la zi. Apoi `git status` + `git diff --stat` și arată-i utilizatorului lista.
   - NU include: `.env`, chei, `.claude/settings.local.json`, build-uri, fișiere mari care nu sunt date de proiect.
   - Dacă apar fișiere pe care nu le-a atins sesiunea asta, întreabă-l dacă intră.
3. **Commit.** Mesaj scurt, în română, la timpul trecut: `Hartă 2D: zoom și pan pe Canvas`. `docs/LOG.md` intră în același commit cu codul.
4. **Sincronizează și trimite.**
   ```bash
   git pull --rebase
   git push
   ```
   - `docs/LOG.md` are `merge=union` în `.gitattributes`: intrările colegilor se combină automat cu ale tale.
   - Dacă apare un conflict în cod, oprește-te și explică-l. Nu forța push-ul (`--force`) niciodată.
   - Dacă nu există remote, spune-i că munca e salvată doar local.
5. Confirmă în 1–2 rânduri: ce s-a trimis, pe ce ramură, și ce a rămas pentru data viitoare.
