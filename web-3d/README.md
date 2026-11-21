# web-3d: harta 3D minimalistă (prototip web)

Prototip web care transformă scanarea 3D a etajului (`../2_11_2025.glb`) într-o hartă 3D minimalistă a holurilor, cu ușile detectate automat. Rulează în browser, inclusiv pe telefon.

**Stare:** un singur etaj (scanarea din rădăcină), holuri + uși. Traseele, pin-urile sălilor și orarul nu sunt încă aici.

## Pornire

```bash
cd web-3d
npm install
npm run dev              # http://localhost:5173
npm run dev -- --host    # accesibil și de pe telefon, în aceeași rețea
```

## Ce face

- **Holuri:** `scripts/extract-floor.mjs` găsește înălțimea podelei, conturul zonei de mers, îl aliniază la axe și îl îndreaptă, apoi construiește pereții pe contur. Rezultatul este `src/map/floor.json`.
- **Uși:** `scripts/detect-doors.mjs` „desfășoară” fiecare perete din scanare (culoare + adâncime) și caută tiparul unei uși: două tocuri verticale până la podea, buiandrug la ~2 m, foaie netedă. Ușile alăturate devin uși duble. Sunt detectate 20 de uși, iar 2–4 sunt ratate (cele cu afișe pe ele).
- **Vizualizare:** React + react-three-fiber. Podea albă, pereți joși (1,4 m), uși chihlimbarii cu covoraș în fața lor, vedere 3D sau de sus, temă luminoasă/întunecată.

## Comenzi

| Comandă | Ce face |
|---|---|
| `npm run extract` | regenerează holurile și ușile din `../2_11_2025.glb` |
| `npm run doors` | regenerează doar ușile |
| `node scripts/wall-elevations.mjs ../2_11_2025.glb src/map/floor.json out.png` | imagine de depanare cu pereții desfășurați |
| `npm run build` | build de producție în `dist/` |

## Structură

```text
web-3d/
├── scripts/
│   ├── extract-floor.mjs     scanare GLB → floor.json (contur + pereți)
│   ├── detect-doors.mjs      uși din scanare → floor.json
│   ├── wall-elevations.mjs   instrument de depanare
│   └── lib/scan.mjs          raycasting (BVH), texturi, PNG
├── src/
│   ├── map/                  floor.json, tipuri
│   ├── three/                Scene, Floor, Walls, Doors, CameraRig, theme
│   └── App.tsx               interfața (bară sus, controale vedere)
└── log.md                    jurnalul modificărilor acestui prototip
```

**Stack:** Vite, React 18, TypeScript, Tailwind v4, three.js, @react-three/fiber, @react-three/drei. Scripturile Node folosesc `@gltf-transform/core`, `three-mesh-bvh` și `jpeg-js`.
