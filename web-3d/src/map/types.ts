export type Vec2 = [number, number]; // [x, z] in meters, app coordinates

export interface FloorPolygon {
  outer: Vec2[];
  holes: Vec2[][];
}

export interface FloorData {
  source: string;
  generatedAt: string;
  cell: number;
  /** scan -> app: translate by -offset, then rotate around Y by rotationY */
  offset: [number, number, number];
  rotationY: number;
  bounds: { minX: number; maxX: number; minZ: number; maxZ: number };
  floor: FloorPolygon[];
  walls: Vec2[][];
  doors: Door[];
}

export interface Door {
  id: string;
  center: Vec2;
  width: number;
  /** unit vector along the wall */
  tangent: Vec2;
  /** unit vector pointing out of the hallway, into the room behind the door */
  normal: Vec2;
  kind: 'single' | 'double';
  score: number;
}
