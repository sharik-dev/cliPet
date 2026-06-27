#!/usr/bin/env python3
# Chat extrait + nettoyage + animations derivees (pattes/queue/oreilles/tenu/chute/atterrissage)
# + pelote. Chars: '.'vide 'X'noir 'g'gris 'w'blanc 'p'rouge 'r'coeur orange
import math

rows0=open("newcat.txt").read().splitlines()
W=max(len(r) for r in rows0); rows0=[r.ljust(W,".") for r in rows0]
while len(rows0)<W: rows0.append("."*W)
CAT=[list(r) for r in rows0[:W]]
for j in range(7,16):                 # retire reflet blanc parasite sur la queue
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
            nc=min(W-1,max(0,c+dx)); g[r][nc]=ch
    return g
def shiftAll(src,dx):
    g=[['.']*W for _ in range(W)]
    for r in range(W):
        for c in range(W):
            nc=c+dx
            if 0<=nc<W: g[r][nc]=src[r][c]
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

BASE=emit(CAT)
idle1=BASE; idle2=emit(bend(CAT,2)); idle3=emit(earDown(CAT)); idle4=emit(bend(CAT,-1))

def walk(lk,ck,rk,tail):
    g=lift2(CAT,PAW_L,lk); g=lift2(g,PAW_C,ck); g=lift2(g,PAW_R,rk); g=bend(g,tail); return emit(g)
walk1=walk(3,1,0,1); walk2=BASE; walk3=walk(0,1,3,-1); walk4=BASE

# Tenu : pattes repliees (tuck) + oreilles baissees + petit gigotement
held1=emit(earDown(tuck(CAT,4)))
held2=emit(shiftAll(earDown(tuck(CAT,4)),1))
# Chute : pattes ecartees, oreilles baissees
fall_g=tuck(CAT,2); fall_g=shiftH(fall_g,PAW_L,-1); fall_g=shiftH(fall_g,PAW_R,1)
fall=emit(earDown(fall_g))
# Atterrissage : pattes ecartees au sol (impact)
land_g=shiftH(CAT,PAW_L,-1); land_g=shiftH(land_g,PAW_R,1)
land=emit(land_g)

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

FRAMES={"idle1":idle1,"idle2":idle2,"idle3":idle3,"idle4":idle4,
        "walk1":walk1,"walk2":walk2,"walk3":walk3,"walk4":walk4,
        "sit":BASE,"sleep":BASE,"play":BASE,
        "held1":held1,"held2":held2,"fall":fall,"land":land}
for i in range(1,5): FRAMES[f"yarn{i}"]=yarn([0,math.pi/8,math.pi/4,3*math.pi/8][i-1])
for n,rws in FRAMES.items():
    exp=YW if n.startswith("yarn") else W
    assert len(rws)==exp and all(len(r)==exp for r in rws), f"{n} {len(rws)}"

def arr(rws): return "[\n        "+",\n        ".join(f'"{r}"' for r in rws)+"\n    ]"
order=["idle1","idle2","idle3","idle4","walk1","walk2","walk3","walk4",
       "sit","sleep","play","held1","held2","fall","land",
       "yarn1","yarn2","yarn3","yarn4"]
out=["// Genere par scripts/gen_sprites.py (chat extrait + animations derivees).","",
     "enum CatSprites {",f"    static let size = {W}",f"    static let yarnSize = {YW}",
     f"    static let idle: [String] = {arr(idle1)}"]
for n in order: out.append(f"    static let {n}: [String] = {arr(FRAMES[n])}")
out+=["", "    static let walk: [[String]] = [walk1, walk2, walk3, walk4]",
      "    static let yarn: [[String]] = [yarn1, yarn2, yarn3, yarn4]","",
      "    static let all: [String: [String]] = ["]
out.append(",\n".join(f'        "{n}": {n}' for n in order))
out+=["    ]","    static let order = ["+", ".join(f'"{n}"' for n in order)+"]","}"]
open("CatSprites.swift","w").write("\n".join(out)+"\n")

from PIL import Image
def dark(c,a): return tuple(int(v*(1-a)) for v in c)
PAL={'.':None,'X':dark((60,64,69),0.6),'g':(150,155,161),'w':(245,245,245),'p':(206,40,40),'r':(242,162,76)}
S=7
def render(rws):
    n=len(rws[0]);h=len(rws);im=Image.new('RGB',(n*S,h*S),(40,40,56));px=im.load()
    for y,r in enumerate(rws):
        for x,ch in enumerate(r):
            c=PAL.get(ch)
            if c:
                for yy in range(S):
                    for xx in range(S): px[x*S+xx,y*S+yy]=c
    return im
labels=[("base",BASE),("held1",held1),("held2",held2),("fall",fall),("land",land)]
ims=[render(f) for _,f in labels]; pad=12
strip=Image.new('RGB',(sum(i.width for i in ims)+pad*4,ims[0].height),(20,20,30)); x=0
for i in ims: strip.paste(i,(x,0)); x+=i.width+pad
strip.save('lift_strip.png'); print("OK size",W)
