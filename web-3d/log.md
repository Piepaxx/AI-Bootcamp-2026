# Change Log

A running record of every change made to the UPT Navigator prototype (hackathon, UPT Timișoara).
Newest entries first. Each entry lists what changed, why, and the files touched.

---

## 2026-11-21 — Rolled back visit360 floors *(uncommitted)*
**What:** Rolled back to commit `01505e0` at the user's request, discarding the ACS multi-floor work
(visit360.upt.ro sketches for Parter / Etaj 3 / Etaj 4, floor switcher, `scripts/visit360-floors.mjs`, `scripts/lib/plan2d.mjs`).
**Recoverable:** the discarded work is saved in `git stash` as "visit360 floors + floor switcher (rolled back)"
(`git stash apply stash@{0}` brings it back).

## 2026-11-21 — Door detection and rendering *(commit `01505e0`)*
**What:** Doors are now detected automatically from the 3D scan and shown in the minimal 3D view.
- Each hallway wall is unrolled into elevation strips (texture color + recess depth) by raycasting the scan.
- Detector looks for the door pattern: two vertical frame edges 0.6–2.0 m apart that reach the floor,
  a consistent lintel line at ~1.9–2.3 m, and a smooth, non-colorful leaf (rejects windows, plants, notice boards).
  Touching leaves are merged into double doors. Result: 20 doors written to `floor.json` as `doors`.
- Rendering: walls get a gap at each door; inside it a muted amber door panel (slightly lower than walls,
  double doors show two leaves) plus a soft amber threshold mat on the hallway floor so doors read in Top view.
  Amber chosen to contrast with gray walls without being harsh, and to stay distinct from the blue accent used later for routes.
- `npm run doors` re-runs detection; `npm run extract` now runs it automatically after floor extraction.

**Known limitations:** 2–4 doors missed (mostly with posters/signs on them, one double door), one glass double
door may appear as two singles, a couple of doors sit at wall corners. Manual correction planned via the map editor.

**Files:** `scripts/detect-doors.mjs` (new), `scripts/lib/scan.mjs` (new: BVH raycasting, texture sampling, PNG writer,
wall sampling), `scripts/wall-elevations.mjs` (new debug tool), `src/three/Doors.tsx` (new), `src/three/Walls.tsx`
(door gaps), `src/three/Scene.tsx`, `src/three/theme.ts`, `src/index.css` (door color tokens), `src/map/types.ts`
(`Door` type), `src/map/floor.json`, `package.json` (scripts, dev deps `three-mesh-bvh`, `jpeg-js`).

## 2026-11-21 — Removed scan overlay *(commit `01505e0`)*
**What:** Removed the "Compare with original scan" feature to save space.
**Why:** It required a second 8.5 MB copy of the scan in `public/`.
**Files:** deleted `src/three/ScanOverlay.tsx` and `public/reference/floor-scan.glb`; updated `src/App.tsx`, `src/three/Scene.tsx`.
**Note:** The first commit still contains the duplicate scan in history; amending it would remove it for good (pending decision).

## 2026-11-21 — Minimal 3D floor view *(commit `b7167d4`)*
**What:** Initial project and the minimal 3D view of one floor, generated from the team's scan.
- Scaffold: Vite + React + TypeScript, Tailwind v4, three.js, @react-three/fiber, @react-three/drei.
- `scripts/extract-floor.mjs`: reads the scan GLB (moved to `assets/reference/floor-scan.glb`), detects the floor
  height, rasterizes walkable floor, extracts the outline, aligns it to the axes, snaps near-axis edges to straight
  lines (orthogonalization), and builds walls along the outline. Output: `src/map/floor.json`.
- Scene: white hallway floor, low 1.4 m "dollhouse" walls with dark caps, soft shadows, flat (no tone mapping) rendering.
- Camera: auto-fits the whole floor (long side along the wider screen axis), animated 3D / Top views, Reset view,
  map-style controls (pan, pinch zoom, rotate; touch friendly).
- UI: top bar, floating view controls, light/dark theme (CSS tokens drive both UI and 3D colors).
- Stairwells are currently walled in (stair geometry reads as wall); to be marked later.

**Files:** `index.html`, `vite.config.ts`, `tsconfig.json`, `package.json`, `.gitignore`, `scripts/extract-floor.mjs`,
`src/main.tsx`, `src/App.tsx`, `src/index.css`, `src/map/*`, `src/three/*`, `assets/reference/floor-scan.glb`.

## 2026-11-21 — Planning
**What:** Implementation plan agreed (structured by feature): 3D floor → routing from all entrances → room pins and search →
room panel (Schedule / Exams tabs, next free slot) → Excel import into Supabase → polish.
**Decisions:** web app (React + R3F + Supabase), 1 building / 1 floor, data from an uploaded Excel,
"next exam scheduling" = the room's next free time slot, existing 3D scan simplified (not shown directly).
