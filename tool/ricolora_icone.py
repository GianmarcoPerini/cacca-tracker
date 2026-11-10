"""Ricolora il corpo delle icone: ogni tipo prende la tinta del suo colore pastello.

Uso: python ricolora.py <cartella_originali> <cartella_uscita> <anteprima.png>
Le originali sono le PNG scontornate (corpo menta o beige).
"""
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont

src, out, prev = sys.argv[1:4]

# corpo di partenza ("menta" o "beige") -> tinta di arrivo (gradi), moltiplicatore saturazione, luminosità
TINTE = {
    "regolare": None,                       # resta menta
    "tanta":   ("menta", 338, 1.30, 1.05),  # rosa
    "morbida": ("menta", 26, 1.25, 1.07),   # pesca
    "dura":    ("beige", 268, 1.15, 0.97),  # lilla
    "liquida": ("beige", 203, 1.35, 1.00),  # azzurro
    "poca":    ("beige", 50, 1.60, 1.02),   # giallo burro
    "niente":  None,
}


def maschera(hsv, corpo):
    h = hsv[..., 0] * 360 / 255
    s = hsv[..., 1] / 255
    v = hsv[..., 2] / 255
    if corpo == "menta":
        return (h > 90) & (h < 200) & (s > 0.10) & (v > 0.45)
    # beige: tinta calda, poco saturo, chiaro (esclude contorno scuro e guance rosa)
    return (h > 22) & (h < 60) & (s > 0.10) & (s < 0.60) & (v > 0.62)


def ricolora(im, corpo, tinta, sat, lum):
    a = np.asarray(im.convert("RGBA"))
    hsv = np.asarray(Image.fromarray(a[..., :3]).convert("HSV")).astype(float)
    m = maschera(hsv, corpo)
    hsv[..., 0] = np.where(m, tinta * 255 / 360, hsv[..., 0])
    hsv[..., 1] = np.where(m, np.clip(hsv[..., 1] * sat, 0, 255), hsv[..., 1])
    hsv[..., 2] = np.where(m, np.clip(hsv[..., 2] * lum, 0, 255), hsv[..., 2])
    rgb = np.asarray(Image.fromarray(hsv.astype("uint8"), "HSV").convert("RGB"))
    return Image.fromarray(np.dstack([rgb, a[..., 3]]), "RGBA")


ordine = ["regolare", "tanta", "poca", "dura", "liquida", "morbida", "niente"]
icone = {}
for n in ordine:
    im = Image.open(f"{src}/{n}.png").convert("RGBA")
    if TINTE[n]:
        im = ricolora(im, *TINTE[n])
    im.save(f"{out}/{n}.png", optimize=True)
    icone[n] = im

# anteprima: tutte grandi, poi coppie a dimensione reale su un cerchio lilla
W = 980
can = Image.new("RGB", (W, 420), (255, 245, 249))
d = ImageDraw.Draw(can)
try:
    f = ImageFont.truetype("arialbd.ttf", 18)
except OSError:
    f = ImageFont.load_default()
for i, n in enumerate(ordine):
    s = icone[n].resize((120, 120), Image.LANCZOS)
    can.paste(s, (14 + i * 138, 14), s)
    d.text((24 + i * 138, 140), n.capitalize(), fill=(69, 54, 90), font=f)
coppie = [("regolare", "dura"), ("tanta", "morbida"), ("regolare", "morbida"), ("tanta", "liquida"),
          ("poca", "dura"), ("poca", "liquida"), ("regolare", "liquida")]
for i, (a_, b_) in enumerate(coppie):
    x, y = 20 + i * 136, 230
    d.ellipse((x, y + 40, x + 66, y + 106), fill=(246, 238, 250))
    d.text((x + 22, y + 62), "8", fill=(69, 54, 90), font=f)
    for k, n in enumerate((a_, b_)):
        s = icone[n].resize((40, 40), Image.LANCZOS)
        can.paste(s, (x + 36 + k * 20, y + 22), s)
    d.text((x, y + 120), f"{a_[:4]}+{b_[:4]}", fill=(110, 94, 128), font=f)
can.save(prev)
print("ok")
