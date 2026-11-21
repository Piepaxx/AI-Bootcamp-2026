# Skill-uri externe (verificate)

Copiate pe 2026-11-21 după un audit read-only de securitate: fără prompt injection, exfiltrare, scripturi rulate automat sau Unicode ascuns. Nu le modifica decât cu notă aici; pentru actualizare, re-auditează versiunea nouă.

| Skill | Sursă @ commit | Licență | Modificări locale |
|---|---|---|---|
| `edge-to-edge` | github.com/android/skills @ c729425 | Apache-2.0 | — |
| `jetpack-compose-performance` | github.com/android/skills @ c729425 | Apache-2.0 | — |
| `android-intent-security` | github.com/android/skills @ c729425 | Apache-2.0 | — |
| `testing-setup` | github.com/android/skills @ c729425 | Apache-2.0 | — (exemplele folosesc Hilt; noi folosim Koin) |
| `compose-animations` | github.com/chrisbanes/skills @ 44522c0 | Apache-2.0 | — |
| `compose-component-design` | github.com/chrisbanes/skills @ 44522c0 | Apache-2.0 | — |
| `compose-state-and-effects` | github.com/chrisbanes/skills @ 44522c0 | Apache-2.0 | — |
| `kotlin-concurrency-and-flow` | github.com/chrisbanes/skills @ 44522c0 | Apache-2.0 | rândul despre `gradle-run` înlocuit cu `./gradlew` din `android/` |
| `material-3-expressive` | github.com/albermonte/android-skills @ 8794e7d | fără fișier LICENSE (distribuit de autor prin `npx skills add`; specificațiile derivă din Material Design) | scoase `scripts/` (refresh cu Playwright) și `agents/openai.yaml` |

Plugin activat în `.claude/settings.json`: `supabase@claude-plugins-official` (github.com/supabase-community/supabase-plugin @ 2c6d02d). Conține skill-urile `supabase` și `supabase-postgres-best-practices` și serverul MCP oficial `https://mcp.supabase.com/mcp` (OAuth). Cu MCP conectat, Claude poate rula SQL pe proiect: conectează-l la proiectul de dev, nu la cel de demo.

Skill-ul `coridor-ui` și hook-urile `guard-secrets.sh` și `kotlin-ui-check.sh` sunt scrise de echipă.
