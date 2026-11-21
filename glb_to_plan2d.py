import trimesh, numpy as np, sys, json
from shapely.geometry import Polygon, MultiPolygon, LineString
from shapely.ops import unary_union
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon as MPoly

src, out = sys.argv[1], sys.argv[2]
m = trimesh.load(src, force='scene').to_geometry()
FLOOR = -1.71
# --- floor footprint: upward faces near floor level, projected to XZ
n = m.face_normals; c = m.triangles_center
up = (n[:,1] > 0.8) & (np.abs(c[:,1]-FLOOR) < 0.25)
tri = m.triangles[up][:, :, [0,2]]
floor = unary_union([Polygon(t).buffer(0.03) for t in tri if Polygon(t).area > 1e-6]).buffer(-0.03)
floor = unary_union([p for p in getattr(floor,'geoms',[floor]) if p.area > 0.5]).simplify(0.05)
# --- stairs: horizontal faces well below/above floor (other levels)
st = (np.abs(n[:,1]) > 0.8) & ((c[:,1] < FLOOR-0.3) | ((c[:,1] > FLOOR+0.25) & (c[:,1] < FLOOR+1.6)))
stp = unary_union([Polygon(t).buffer(0.05) for t in m.triangles[st][:,:,[0,2]] if Polygon(t).area>1e-6]).buffer(-0.05)
stairs = [p for p in getattr(stp,'geoms',[stp]) if p.area > 0.8]
# --- walls: slice at several heights above floor
segs = []
for h in (0.9, 1.2, 1.5):
    sec = m.section(plane_origin=[0, FLOOR+h, 0], plane_normal=[0,1,0])
    if sec is None: continue
    for e in sec.entities:
        pts = sec.vertices[e.points][:, [0,2]]
        segs.append(pts)
walls = unary_union([LineString(p).buffer(0.06, cap_style=2) for p in segs if len(p) > 1])
walls = unary_union([p for p in getattr(walls,'geoms',[walls]) if p.area > 0.02]).simplify(0.02)

def polys(g): return [p for p in getattr(g,'geoms',[g]) if not p.is_empty]

xmin,zmin,xmax,zmax = unary_union([floor, walls]).bounds
W, H = xmax-xmin, zmax-zmin
fig, ax = plt.subplots(figsize=(W/2.2+1.5, H/2.2+1.5), dpi=150)
ax.set_facecolor("white")
for p in polys(floor):
    ax.add_patch(MPoly(np.array(p.exterior.coords), fc="#e9eef5", ec="none"))
    for i in p.interiors: ax.add_patch(MPoly(np.array(i.coords), fc="white", ec="none"))
for p in stairs:
    ax.add_patch(MPoly(np.array(p.exterior.coords), fc="#fde7c8", ec="#d08a2a", lw=0.8, hatch="////"))
for p in polys(walls):
    ax.add_patch(MPoly(np.array(p.exterior.coords), fc="#1f2937", ec="none"))
    for i in p.interiors: ax.add_patch(MPoly(np.array(i.coords), fc="#e9eef5", ec="none"))
# grid every 1m, labels every 5m
ax.set_xticks(np.arange(np.floor(xmin), xmax+1, 5)); ax.set_yticks(np.arange(np.floor(zmin), zmax+1, 5))
ax.set_xticks(np.arange(np.floor(xmin), xmax+1, 1), minor=True); ax.set_yticks(np.arange(np.floor(zmin), zmax+1, 1), minor=True)
ax.grid(which="minor", color="#cbd5e1", lw=0.3); ax.grid(which="major", color="#94a3b8", lw=0.6)
ax.set_axisbelow(True)
# scale bar 5 m
sx, sz = xmax-6, zmax-0.8
ax.plot([sx, sx+5], [sz, sz], color="k", lw=3); ax.text(sx+2.5, sz-0.4, "5 m", ha="center", fontsize=9)
ax.set_xlim(xmin-1, xmax+1); ax.set_ylim(zmax+1, zmin-1)   # -Z = "sus" pe hartă, ca în viewer-ul GLB
ax.set_aspect("equal"); ax.tick_params(labelsize=7)
ax.set_xlabel("X (m)"); ax.set_ylabel("Z (m)")
ax.set_title("Plan 2D generat din scanarea 3D – 2_11_2025.glb", fontsize=10)
plt.tight_layout()
plt.savefig(out+".png"); plt.savefig(out+".svg")
# geometry for the app (metric, same coords as the GLB: x, z)
geo = {"units":"m","axes":"x,z of GLB (y up)","floor_y":FLOOR,
       "floor":[np.round(np.array(p.exterior.coords),3).tolist() for p in polys(floor)],
       "walls":[np.round(np.array(p.exterior.coords),3).tolist() for p in polys(walls)],
       "stairs":[np.round(np.array(p.exterior.coords),3).tolist() for p in stairs]}
json.dump(geo, open(out+".json","w"))
print("floor m2", round(floor.area,1), "walls", len(polys(walls)), "stairs", len(stairs), "bbox", round(W,1), round(H,1))
