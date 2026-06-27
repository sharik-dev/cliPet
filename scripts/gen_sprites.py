#!/usr/bin/env python3
# Chat (marche extraite ref + sit extrait img#5) composite sur canevas 40x40
# (sit plus grand) + pelote 12x12.
# Chars: '.'vide 'X'noir 'g'gris 'w'blanc 'p'rouge 'r'orange
import math

CANVAS=33
rows0=open("newcat.txt").read().splitlines()
W0=max(len(r) for r in rows0); rows0=[r.ljust(W0,".") for r in rows0]
while len(rows0)<W0: rows0.append("."*W0)
CAT=[list(r) for r in rows0[:W0]]
for j in range(7,16):
    for i in range(4,10):
        if CAT[j][i]=='w': CAT[j][i]='X'

def cp(g): return [r[:] for r in g]
def emit(g): return ["".join(r) for r in g]
def lift2(src,box,k):
    if not k: return cp(src)
    r0,r1,c0,c1=box; g=cp(src)
    for c in range(c0,c1+1):
        for r in range(r0,r1+1):
            s=r+k; g[r][c]=src[s][c] if s<=r1 else '.'
    return g
def shiftH(src,box,dx):
    r0,r1,c0,c1=box; g=cp(src)
    for r in range(r0,r1+1):
        for c in range(c0,c1+1): g[r][c]='.'
    for r in range(r0,r1+1):
        for c in range(c0,c1+1):
            ch=src[r][c]
            if ch=='.': continue
            nc=min(W0-1,max(0,c+dx)); g[r][nc]=ch
    return g
def shiftAll(src,dx):
    g=[['.']*W0 for _ in range(W0)]
    for r in range(W0):
        for c in range(W0):
            nc=c+dx
            if 0<=nc<W0: g[r][nc]=src[r][c]
    return g
PAW_L=(27,32,0,7); PAW_C=(27,32,11,19); PAW_R=(24,31,20,28)
TAIL=(2,14,0,8); EAR=(0,4,21,29)
def bend(src,a):
    if a==0: return cp(src)
    r0,r1,c0,c1=TAIL; g=cp(src)
    for r in range(r0,r1+1):
        for c in range(c0,c1+1): g[r][c]='.'
    for r in range(r0,r1+1):
        t=1-(r-r0)/(r1-r0); dx=int(round(a*t))
        for c in range(c0,c1+1):
            ch=src[r][c]
            if ch=='.': continue
            nc=min(c1,max(c0,c+dx)); g[r][nc]=ch
    return g
def earDown(src):
    r0,r1,c0,c1=EAR; g=cp(src)
    for c in range(c0,c1+1):
        for r in range(r1,r0,-1): g[r][c]=src[r-1][c]
        g[r0][c]='.'
    return g
def tuck(src,k):
    g=lift2(src,PAW_L,k); g=lift2(g,PAW_C,k); g=lift2(g,PAW_R,k); return g

# Composite un sprite (liste de str) sur canevas CANVASxCANVAS, bas-centre
def canvas(rows):
    h=len(rows); w=len(rows[0])
    lpad=(CANVAS-w)//2; top=CANVAS-h
    out=[]
    for _ in range(top): out.append("."*CANVAS)
    for r in rows:
        out.append("."*lpad + r + "."*(CANVAS-w-lpad))
    return out

# --- frames de marche/idle (base 33) ---
BASE33=emit(CAT)
idle1=BASE33; idle2=emit(bend(CAT,2)); idle3=emit(earDown(CAT)); idle4=emit(bend(CAT,-1))
def walk(lk,ck,rk,tail):
    g=lift2(CAT,PAW_L,lk); g=lift2(g,PAW_C,ck); g=lift2(g,PAW_R,rk); g=bend(g,tail); return emit(g)
walk1=walk(3,1,0,1); walk2=BASE33; walk3=walk(0,1,3,-1); walk4=BASE33
held1=emit(earDown(tuck(CAT,4))); held2=emit(shiftAll(earDown(tuck(CAT,4)),1))
fg=tuck(CAT,2); fg=shiftH(fg,PAW_L,-1); fg=shiftH(fg,PAW_R,1); fall=emit(earDown(fg))
lg=shiftH(CAT,PAW_L,-1); lg=shiftH(lg,PAW_R,1); land=emit(lg)

# --- sit (img#5) + contour ---
sit=[list(r) for r in open("sit6.txt").read().splitlines()]
sh=len(sit); sw=max(len(r) for r in sit)
sit=[ (r+['.']*(sw-len(r))) for r in sit]
def outline(g):
    H=len(g); Wd=len(g[0]); out=cp(g)
    for y in range(H):
        for x in range(Wd):
            if g[y][x]=='.' and any(0<=x+dx<Wd and 0<=y+dy<H and g[y+dy][x+dx] in ('g','w','p','r')
                   for dx,dy in [(-1,0),(1,0),(0,-1),(0,1)]): out[y][x]='X'
    return out
SIT=emit(outline(sit))

CATFRAMES={"idle1":idle1,"idle2":idle2,"idle3":idle3,"idle4":idle4,
           "walk1":walk1,"walk2":walk2,"walk3":walk3,"walk4":walk4,
           "held1":held1,"held2":held2,"fall":fall,"land":land,"play":BASE33,
           "sit":BASE33,"sleep":BASE33}
FRAMES={n:canvas(f) for n,f in CATFRAMES.items()}

YW=12
def yarn(angle):
    g=[['.']*YW for _ in range(YW)]; cx=cy=5.5; r=4.7
    for y in range(YW):
        for x in range(YW):
            if math.hypot(x-cx,y-cy)<=r: g[y][x]='p'
    for k in range(4):
        a=angle+k*math.pi/2
        for t in range(int(r)+1):
            x=int(round(cx+math.cos(a)*t)); y=int(round(cy+math.sin(a)*t))
            if 0<=x<YW and 0<=y<YW and g[y][x]=='p': g[y][x]='X'
    hx,hy=int(cx-2),int(cy-2)
    if g[hy][hx] in ('p','X'): g[hy][hx]='r'
    for y in range(YW):
        for x in range(YW):
            if g[y][x]=='.' and any(0<=x+dx<YW and 0<=y+dy<YW and g[y+dy][x+dx] in ('p','X','r')
                   for dx,dy in [(-1,0),(1,0),(0,-1),(0,1)]): g[y][x]='X'
    g[YW-2][YW-3]='X'; g[YW-1][YW-2]='X'
    return ["".join(r) for r in g]
for i in range(1,5): FRAMES[f"yarn{i}"]=yarn([0,math.pi/8,math.pi/4,3*math.pi/8][i-1])

for n,rws in FRAMES.items():
    exp=YW if n.startswith("yarn") else CANVAS
    assert len(rws)==exp and all(len(r)==exp for r in rws), f"{n} {len(rws)}x{len(rws[0])}"

def arr(rws): return "[\n        "+",\n        ".join(f'"{r}"' for r in rws)+"\n    ]"
order=["idle1","idle2","idle3","idle4","walk1","walk2","walk3","walk4",
       "sit","sleep","play","held1","held2","fall","land","yarn1","yarn2","yarn3","yarn4"]
out=["// Genere par scripts/gen_sprites.py (canevas 40x40 ; sit = img#5).","",
     "enum CatSprites {",f"    static let size = {CANVAS}",f"    static let yarnSize = {YW}",
     f"    static let idle: [String] = {arr(FRAMES['idle1'])}"]
for n in order: out.append(f"    static let {n}: [String] = {arr(FRAMES[n])}")
out+=["", "    static let walk: [[String]] = [walk1, walk2, walk3, walk4]",
      "    static let yarn: [[String]] = [yarn1, yarn2, yarn3, yarn4]","",
      "    static let all: [String: [String]] = ["]
out.append(",\n".join(f'        "{n}": {n}' for n in order))
out+=["    ]","    static let order = ["+", ".join(f'"{n}"' for n in order)+"]","}"]
open("CatSprites.swift","w").write("\n".join(out)+"\n")
print("OK canvas",CANVAS,"sit",sw,"x",sh)
