#!/usr/bin/env python3
"""Génère l'AppIcon macOS de cliPet à partir du pet « Cœur gris ».
Lit le sprite depuis site/script.js (source unique), le rend sur un fond
arrondi sombre, et écrit toutes les tailles dans Assets.xcassets/AppIcon.appiconset/.
"""
import json, os, re
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IIN = os.path.join(ROOT, "site", "script.js")
OUT = os.path.join(ROOT, "cliPet", "Assets.xcassets", "AppIcon.appiconset")

# Palette de marque (miroir de l'app).
PAL = {".": None, "X": "#17191C", "g": "#969BA1", "w": "#F5F5F5", "p": "#CE2828", "r": "#F2A24C"}

# Extrait SPRITES depuis script.js.
src = open(IIN, encoding="utf-8").read()
m = re.search(r"var SPRITES\s*=\s*(\{.*?\});", src, re.S)
SPRITES = json.loads(m.group(1))
frame = SPRITES["sit"]
H, W = len(frame), max(len(r) for r in frame)

S = 1024
base = Image.new("RGBA", (S, S), (0, 0, 0, 0))
draw = ImageDraw.Draw(base)

# Fond arrondi avec dégradé vertical sombre.
margin, radius = 96, 210
grad = Image.new("RGBA", (S, S), (0, 0, 0, 0))
top, bot = (0x2A, 0x2F, 0x37), (0x14, 0x17, 0x1C)
for y in range(S):
    t = y / S
    r = int(top[0] + (bot[0] - top[0]) * t)
    g = int(top[1] + (bot[1] - top[1]) * t)
    b = int(top[2] + (bot[2] - top[2]) * t)
    for x in range(0):  # placeholder
        pass
    ImageDraw.Draw(grad).line([(0, y), (S, y)], fill=(r, g, b, 255))
mask = Image.new("L", (S, S), 0)
ImageDraw.Draw(mask).rounded_rectangle([margin, margin, S - margin, S - margin], radius=radius, fill=255)
base.paste(grad, (0, 0), mask)

# Rendu du chat (pixels nets) centré.
cell = int((S - 2 * margin) * 0.74 / W)
cat_w, cat_h = W * cell, H * cell
ox = (S - cat_w) // 2
oy = (S - cat_h) // 2 + int(cell * 0.5)  # léger décalage bas

# Halo lumineux derrière le chat (détache le contour foncé du fond sombre).
glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
gd = ImageDraw.Draw(glow)
cx, cy = S // 2, oy + cat_h // 2
gd.ellipse([cx - cat_w * 0.62, cy - cat_h * 0.58, cx + cat_w * 0.62, cy + cat_h * 0.58],
           fill=(150, 170, 190, 90))
glow = glow.filter(ImageFilter.GaussianBlur(70))
base = Image.alpha_composite(base, Image.composite(glow, Image.new("RGBA", (S, S), (0, 0, 0, 0)), mask))
draw = ImageDraw.Draw(base)
for y, row in enumerate(frame):
    for x, ch in enumerate(row):
        col = PAL.get(ch)
        if not col:
            continue
        px = ox + x * cell
        py = oy + y * cell
        draw.rectangle([px, py, px + cell - 1, py + cell - 1], fill=col)

# Tailles macOS : (taille_px, nom).
SIZES = [
    (16, "icon_16x16.png"), (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"), (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"), (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"), (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"), (1024, "icon_512x512@2x.png"),
]
os.makedirs(OUT, exist_ok=True)
for px, name in SIZES:
    base.resize((px, px), Image.LANCZOS).save(os.path.join(OUT, name))

# Contents.json macOS.
contents = {"images": [], "info": {"author": "xcode", "version": 1}}
for size, scale, name in [
    ("16x16", "1x", "icon_16x16.png"), ("16x16", "2x", "icon_16x16@2x.png"),
    ("32x32", "1x", "icon_32x32.png"), ("32x32", "2x", "icon_32x32@2x.png"),
    ("128x128", "1x", "icon_128x128.png"), ("128x128", "2x", "icon_128x128@2x.png"),
    ("256x256", "1x", "icon_256x256.png"), ("256x256", "2x", "icon_256x256@2x.png"),
    ("512x512", "1x", "icon_512x512.png"), ("512x512", "2x", "icon_512x512@2x.png"),
]:
    contents["images"].append({"idiom": "mac", "size": size, "scale": scale, "filename": name})
json.dump(contents, open(os.path.join(OUT, "Contents.json"), "w"), indent=2)
print("AppIcon généré dans", OUT)

# --- Fond de la fenêtre du DMG (dégradé sombre + flèche vers Applications) ---
DW, DH = 720, 460
dmg = Image.new("RGBA", (DW, DH), (0, 0, 0, 255))
dd = ImageDraw.Draw(dmg)
for y in range(DH):
    t = y / DH
    c = (int(0x1C + (0x0F - 0x1C) * t), int(0x20 + (0x12 - 0x20) * t), int(0x26 + (0x17 - 0x26) * t))
    dd.line([(0, y), (DW, y)], fill=c + (255,))
# Flèche entre les deux icônes (app à gauche ~190, Applications à droite ~530).
ay = 215
dd.line([(300, ay), (420, ay)], fill=(0x4A, 0xA3, 0xA3, 255), width=8)
dd.polygon([(420, ay - 16), (452, ay), (420, ay + 16)], fill=(0x4A, 0xA3, 0xA3, 255))
dmg.convert("RGB").save(os.path.join(ROOT, "scripts", "dmg-bg.png"))
print("Fond DMG généré : scripts/dmg-bg.png")
