---
name: log
description: Adaugă sau actualizează intrarea sesiunii curente în docs/LOG.md (ora, autorul, ce s-a făcut, decizii, ce a rămas). Folosește-l la finalul fiecărei bucăți de lucru sau când utilizatorul spune „notează în jurnal”.
---

# /log: scrie în jurnalul echipei

`docs/LOG.md` e memoria comună a echipei. Patru oameni lucrează din conturi Claude diferite, deci ce nu e scris aici se pierde.

## Pași

1. Generează titlul cu ora și autorul. Nu le scrie de mână:
   ```bash
   bash .claude/scripts/log-header.sh <primele 8 caractere din id-ul sesiunii, din mesajul SessionStart>
   ```
2. Verifică dacă sesiunea are deja o intrare în LOG.md (același id de sesiune în titlu).
   - **Are:** actualizeaz-o. Păstrează ora de început și adaugă ora curentă: `## 2026-11-21 09:27–11:40 · …`.
   - **Nu are:** inserează una nouă **imediat sub** linia `<!-- INTRĂRI NOI AICI: cele mai noi primele -->`.
3. Completează după șablonul din `CLAUDE.md` (secțiunea Jurnal). Reguli:
   - Fapte concrete, nu povești. Numește fișierele și funcțiile.
   - **Ce a rămas** e partea cea mai importantă: următorul om (sau Claude) trebuie să poată continua doar din ea.
   - O decizie care schimbă ceva marcat DECIS în `CONTEXT.md` se trece și acolo.
   - Fără chei API, parole sau date personale.
4. Dacă s-au adăugat module sau foldere noi, actualizează și `docs/ARCHITECTURE.md`.
5. Arată-i utilizatorului intrarea în 2–3 rânduri și amintește-i de `/finish` (commit + push), ca munca să ajungă la colegi.
