import { useMemo } from 'react';
import * as THREE from 'three';
import { mergeGeometries } from 'three/examples/jsm/utils/BufferGeometryUtils.js';
import { floorData } from '../map/floor';
import { WALL_HEIGHT, WALL_THICKNESS } from './Walls';

const PANEL_HEIGHT = WALL_HEIGHT - 0.3; // a bit lower than the walls so doors read as openings
const PANEL_THICKNESS = 0.07;
const GAP = 0.04; // gap between panel and the wall ends / between double-door leaves
const MAT_DEPTH = 0.55; // threshold mat on the hallway floor, visible from the top view

function build() {
  const panels: THREE.BufferGeometry[] = [];
  const edges: THREE.BufferGeometry[] = [];
  const mats: THREE.BufferGeometry[] = [];
  for (const d of floorData.doors ?? []) {
    const angle = -Math.atan2(d.tangent[1], d.tangent[0]);
    const [cx, cz] = d.center;
    const [nx, nz] = d.normal;
    const [tx, tz] = d.tangent;
    const leaves = d.kind === 'double' ? 2 : 1;
    const leafW = (d.width - GAP * (leaves + 1)) / leaves;
    for (let k = 0; k < leaves; k++) {
      const off = -d.width / 2 + GAP + leafW / 2 + k * (leafW + GAP);
      const px = cx + tx * off, pz = cz + tz * off;
      const g = new THREE.BoxGeometry(leafW, PANEL_HEIGHT, PANEL_THICKNESS);
      g.rotateY(angle);
      g.translate(px, PANEL_HEIGHT / 2, pz);
      panels.push(g);
      // darker top edge for definition (matches the wall caps)
      const e = new THREE.BoxGeometry(leafW, 0.03, PANEL_THICKNESS + 0.01);
      e.rotateY(angle);
      e.translate(px, PANEL_HEIGHT + 0.015, pz);
      edges.push(e);
    }
    // threshold mat, slightly inset from the wall on the hallway side
    const m = new THREE.BoxGeometry(d.width, 0.012, MAT_DEPTH);
    m.rotateY(angle);
    const back = WALL_THICKNESS / 2 + MAT_DEPTH / 2;
    m.translate(cx - nx * back, 0.066, cz - nz * back);
    mats.push(m);
  }
  const merge = (g: THREE.BufferGeometry[]) => (g.length ? mergeGeometries(g) : null);
  return { panels: merge(panels), edges: merge(edges), mats: merge(mats) };
}

export function Doors({ color, edgeColor, matColor }: { color: string; edgeColor: string; matColor: string }) {
  const geo = useMemo(build, []);
  if (!geo.panels) return null;
  return (
    <group>
      <mesh geometry={geo.panels} castShadow receiveShadow>
        <meshStandardMaterial color={color} roughness={0.7} />
      </mesh>
      {geo.edges && (
        <mesh geometry={geo.edges}>
          <meshStandardMaterial color={edgeColor} roughness={0.6} />
        </mesh>
      )}
      {geo.mats && (
        <mesh geometry={geo.mats} receiveShadow>
          <meshStandardMaterial color={matColor} roughness={1} />
        </mesh>
      )}
    </group>
  );
}
