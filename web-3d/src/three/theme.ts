export type ThemeName = 'light' | 'dark';

export interface SceneColors {
  bg: string;
  ground: string;
  floor: string;
  wall: string;
  wallTop: string;
  door: string;
  doorEdge: string;
  doorMat: string;
}

/** Reads the scene color tokens from CSS so the 3D scene follows the theme. */
export function readSceneColors(): SceneColors {
  const s = getComputedStyle(document.documentElement);
  const v = (name: string) => s.getPropertyValue(name).trim();
  return {
    bg: v('--scene-bg'),
    ground: v('--scene-ground'),
    floor: v('--scene-floor'),
    wall: v('--scene-wall'),
    wallTop: v('--scene-wall-top'),
    door: v('--scene-door'),
    doorEdge: v('--scene-door-edge'),
    doorMat: v('--scene-door-mat'),
  };
}
