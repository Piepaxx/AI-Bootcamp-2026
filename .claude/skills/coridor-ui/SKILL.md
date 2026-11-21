---
name: coridor-ui
description: Regulile de UI/UX ale aplicației Coridor (Android, Compose, Material 3). Folosește-l ÎNAINTE de a crea sau modifica orice ecran sau componentă Compose din android/ (Acasă, Orar, Hartă, RoomSheet, căutare, QR), și când utilizatorul cere „mai frumos”, „polish”, „design” sau un review de UI.
---

# Coridor UI

UX-ul Android e prioritatea maximă a echipei (`CONTEXT.md` §10, DECIS). Acest skill leagă principiile de acolo de skill-urile tehnice instalate.

## Înainte să scrii cod

1. Citește `CONTEXT.md` §10 (cele 10 principii) și verifică ce componente există deja în `android/.../ui/components/`.
2. Refolosește componentele din biblioteca comună: `NextClassCard`, `RoomSheet`, `RoomPin`, `FloorChips`, `RouteSteps`, `TimetableDay`, `SearchBar`. Dacă lipsește una, o creezi acolo (nu în ecran), după skill-ul `compose-component-design`.
3. Culorile, fonturile, formele și spațierile vin **doar** din tema Material 3 (`ui/theme/`). Hook-ul `kotlin-ui-check` semnalează valorile scrise direct.

## Skill-uri de folosit, după caz

| Ce faci | Skill |
|---|---|
| Ierarhie vizuală, culoare, formă, motion „expresiv” | `material-3-expressive` |
| API-ul unei componente reutilizabile | `compose-component-design` |
| Stare, `remember`, `LaunchedEffect`, colectarea Flow | `compose-state-and-effects` |
| Animații (puls pe pin, tranziții, bottom sheet) | `compose-animations` |
| Bare de sistem, insets, tastatură | `edge-to-edge` |
| Harta 2D sacadează / recompuneri multe | `jetpack-compose-performance` |
| ViewModel, StateFlow, coroutine | `kotlin-concurrency-and-flow` |
| App Links `/q/<id>`, intent-uri din QR | `android-intent-security` |
| Teste UI și screenshot | `testing-setup` (proiectul folosește Koin, nu Hilt) |

## Lista de verificare la final (fiecare ecran)

- [ ] Primul ecran răspunde la „unde am ora următoare?” fără scroll.
- [ ] Orice sală e la ≤ 2 tap-uri de hartă.
- [ ] Zone de atingere ≥ 48dp, contrast AA, `contentDescription` pe iconițele care fac ceva.
- [ ] Arată bine în mod luminos **și** întunecat, și cu fontul mărit la 200%.
- [ ] Stări goale, de încărcare și offline au text în română („Offline · date din 21 nov”).
- [ ] Codurile de sală apar cu explicație („B623 · Corp B · etaj 6”).
- [ ] Edge-to-edge: nimic acoperit de bara de stare sau de navigare.
- [ ] Există un `@Preview` (luminos + întunecat) pentru fiecare componentă nouă.
- [ ] Ai compilat (`./gradlew :app:compileDebugKotlin` din `android/`) și, dacă se poate, ai văzut ecranul pe emulator (skill-ul `run`).

Textele pentru utilizator sunt în română. Identificatorii din cod sunt în engleză.
