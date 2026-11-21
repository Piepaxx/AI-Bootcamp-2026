---
name: start
description: Începe o sesiune de lucru în echipă - aduce ultimele schimbări de pe GitHub, citește jurnalul și rezumă ce au făcut colegii și ce a rămas de făcut. Folosește-l la începutul sesiunii sau când utilizatorul întreabă „ce s-a mai făcut?”.
---

# /start: preia lucrul de la colegi

1. **Sincronizează.** Rulează `git status`.
   - Dacă există modificări necommise, întreabă utilizatorul ce face cu ele înainte de pull. Nu le șterge și nu face stash fără acord.
   - Altfel: `git pull --rebase`. Dacă apare un conflict, oprește-te și explică-l. Nu-l rezolva pe ghicite.
2. **Citește** în `docs/LOG.md` intrările din ultimele ~24 h (sau ultimele 5, dacă sunt mai vechi).
3. **Rezumă** pentru utilizator, scurt:
   - cine ce a făcut (autor + oră);
   - deciziile noi;
   - **ce a rămas deschis**, grupat pe rolurile din `CONTEXT.md` §11, cu accent pe ce ține de rolul utilizatorului;
   - eventualele suprapuneri (doi oameni pe același fișier sau modul).
4. Propune 1–3 sarcini concrete cu care poate începe. Nu începe codul până nu alege.
