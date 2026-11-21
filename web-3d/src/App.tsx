import { useLayoutEffect, useState, type ReactNode } from 'react';
import { Box, Layers, Map as MapIcon, Moon, RotateCcw, Sun } from 'lucide-react';
import { Scene } from './three/Scene';
import type { ViewMode } from './three/CameraRig';
import { readSceneColors, type SceneColors, type ThemeName } from './three/theme';

function initialTheme(): ThemeName {
  try {
    const saved = localStorage.getItem('theme');
    if (saved === 'light' || saved === 'dark') return saved;
  } catch {
    /* storage unavailable */
  }
  return window.matchMedia?.('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

export default function App() {
  const [theme, setTheme] = useState<ThemeName>(initialTheme);
  const [colors, setColors] = useState<SceneColors | null>(null);
  const [view, setView] = useState<ViewMode>('3d');
  const [resetKey, setResetKey] = useState(0);

  useLayoutEffect(() => {
    document.documentElement.dataset.theme = theme;
    try {
      localStorage.setItem('theme', theme);
    } catch {
      /* ignore */
    }
    setColors(readSceneColors());
  }, [theme]);

  return (
    <div className="relative h-full w-full">
      {colors && <Scene colors={colors} view={view} resetKey={resetKey} dark={theme === 'dark'} />}

      {/* top bar */}
      <header className="pointer-events-none absolute inset-x-0 top-0 flex justify-center p-3 sm:justify-start sm:p-4">
        <div className="pointer-events-auto flex items-center gap-3 rounded-2xl border border-border bg-surface px-4 py-2.5 shadow-lg shadow-black/5 backdrop-blur-xl">
          <div className="grid h-9 w-9 place-items-center rounded-xl bg-accent text-white">
            <MapIcon size={18} />
          </div>
          <div className="leading-tight">
            <div className="text-[15px] font-semibold tracking-tight">UPT Navigator</div>
            <div className="text-xs text-muted">Floor plan · hallways</div>
          </div>
        </div>
      </header>

      {/* view controls */}
      <div className="absolute right-3 bottom-[max(0.75rem,env(safe-area-inset-bottom))] flex flex-col items-end gap-2 sm:right-4 sm:bottom-4">
        <div className="flex rounded-xl border border-border bg-surface p-1 shadow-lg shadow-black/5 backdrop-blur-xl">
          <Segment active={view === '3d'} onClick={() => { setView('3d'); setResetKey((k) => k + 1); }} icon={<Box size={16} />} label="3D" />
          <Segment active={view === 'top'} onClick={() => { setView('top'); setResetKey((k) => k + 1); }} icon={<Layers size={16} />} label="Top" />
        </div>
        <div className="flex gap-2">
          <IconButton label={theme === 'dark' ? 'Light theme' : 'Dark theme'} onClick={() => setTheme((t) => (t === 'dark' ? 'light' : 'dark'))}>
            {theme === 'dark' ? <Sun size={18} /> : <Moon size={18} />}
          </IconButton>
          <IconButton label="Reset view" onClick={() => setResetKey((k) => k + 1)}>
            <RotateCcw size={18} />
          </IconButton>
        </div>
      </div>

      {/* hint */}
      <div className="pointer-events-none absolute bottom-[max(0.75rem,env(safe-area-inset-bottom))] left-3 hidden rounded-xl border border-border bg-surface px-3 py-2 text-xs text-muted shadow-lg shadow-black/5 backdrop-blur-xl sm:left-4 sm:bottom-4 md:block">
        Drag to pan · Right-drag to rotate · Scroll to zoom
      </div>
    </div>
  );
}

function Segment({ active, onClick, icon, label }: { active: boolean; onClick: () => void; icon: ReactNode; label: string }) {
  return (
    <button
      onClick={onClick}
      aria-pressed={active}
      className={`flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-sm font-medium transition-colors ${
        active ? 'bg-accent text-white shadow-sm' : 'text-muted hover:text-text'
      }`}
    >
      {icon}
      {label}
    </button>
  );
}

function IconButton({ label, onClick, active, children }: { label: string; onClick: () => void; active?: boolean; children: ReactNode }) {
  return (
    <button
      onClick={onClick}
      title={label}
      aria-label={label}
      aria-pressed={active}
      className={`grid h-11 w-11 place-items-center rounded-xl border border-border shadow-lg shadow-black/5 backdrop-blur-xl transition-colors ${
        active ? 'bg-accent text-white' : 'bg-surface text-text hover:bg-accent-soft'
      }`}
    >
      {children}
    </button>
  );
}
