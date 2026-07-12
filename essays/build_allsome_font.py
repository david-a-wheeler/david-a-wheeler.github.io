#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "fonttools[woff]",
#     "shapely",
#     "pillow",
# ]
# ///
"""Build allsome.woff2 (Option A2, all-original glyphs, CC0).

Contains three glyphs, all drawn from scratch (no third-party outlines):
  * forall  (U+2200)  -- normal-looking, XITS-ish metrics (adv 560, height 662)
  * exists  (U+2203)  -- ditto
  * allsome (U+E900)  -- the merged for-all/there-exists mark (\\allsome design)
A GSUB 'liga' maps  forall exists -> allsome, so an immediate forall+exists
pair renders as the merged mark. Solo forall/exists render normally, so the
font is safe to combine with a base math font even if applied globally.

Writes allsome.ttf and allsome.woff2 into the current directory. The .woff2 is
derived from the .ttf, so the two cannot drift apart.

To run it, with no setup at all:

    uv run build_allsome_font.py

The dependencies are declared in the PEP 723 block above, so uv fetches them into
a throwaway environment. Without uv, install fonttools[woff] (the [woff] extra
supplies the Brotli compressor that .woff2 needs), shapely, and pillow, then run
the script with an ordinary python3.

Dedicated to the public domain (CC0 1.0).
"""
from pathlib import Path
import shapely
from shapely.geometry import LineString
from shapely.ops import unary_union
from shapely.geometry.polygon import orient
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.feaLib.builder import addOpenTypeFeaturesFromString
from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw

# Outputs go in the current directory, wherever this script happens to live.
TTF   = Path("allsome.ttf")
WOFF2 = Path("allsome.woff2")

UPM    = 1000
CAPH   = 662             # match XITS forall/exists height
S      = CAPH / 1.4      # local (0..1.4) -> font units
STROKE = 0.12            # stroke thickness in local units
ADV_QF = 560             # advance for forall/exists (match XITS)
SB_MERGE = 80            # side bearing for the merged glyph

# centerlines in local coords (y up, cap height = 1.4)
# The for-all crossbar sits high (y=0.95) so the inverted-A triangle below it
# is large and clearly readable; the exists middle prong sits at y=0.80.
forall_segs = [[(0.55,0),(0.0,1.4)], [(0.55,0),(1.1,1.4)], [(0.177,0.95),(0.923,0.95)]]
exists_segs = [[(0.85,0),(0.85,1.4)], [(0,1.4),(0.85,1.4)],
               [(0,0.80),(0.85,0.80)], [(0,0),(0.85,0)]]
# the merged mark: forall strokes + exists strokes sharing the bottom-left
allsome_segs = [[(0,0),(-0.5,1.4)], [(0,0),(0.5,1.4)], [(-0.339,0.95),(0.339,0.95)],
                [(1.4,0),(1.4,1.4)], [(0,0),(1.4,0)], [(0.5,1.4),(1.4,1.4)],
                [(1.4,0.80),(0.80,0.80)]]

def stroke_geom(segs, cap):
    parts = [LineString(s).buffer(STROKE/2.0, cap_style=cap, join_style="mitre",
                                  mitre_limit=5.0) for s in segs]
    return unary_union(parts)

def geom_rings(geom):
    polys = list(geom.geoms) if geom.geom_type == "MultiPolygon" else [geom]
    rings = []
    for p in polys:
        p = orient(p, sign=-1.0)          # exterior CW, holes CCW (TrueType)
        rings.append(list(p.exterior.coords)[:-1])
        for hole in p.interiors:
            rings.append(list(hole.coords)[:-1])
    return rings

def place(geom, advance=None):
    """Scale to font units, drop to baseline (miny=0); center in `advance` if
    given, else advance = width + 2*SB_MERGE. Returns (rings, advance, lsb)."""
    rings = [[(x*S, y*S) for (x, y) in r] for r in geom_rings(geom)]
    xs = [p[0] for r in rings for p in r]; ys = [p[1] for r in rings for p in r]
    minx, maxx, miny = min(xs), max(xs), min(ys)
    w = maxx - minx
    if advance is None:
        advance = round(w + 2*SB_MERGE); lsb = SB_MERGE
    else:
        lsb = (advance - w) / 2.0
    dx = lsb - minx
    out = [[(round(x+dx), round(y-miny)) for (x, y) in r] for r in rings]
    real_min = min(p[0] for r in out for p in r)
    return out, advance, real_min

glyphs_geom = {
    "forall":  (stroke_geom(forall_segs, "flat"),   ADV_QF),
    "exists":  (stroke_geom(exists_segs, "flat"),   ADV_QF),
    "allsome": (stroke_geom(allsome_segs, "square"), None),
}
placed = {n: place(g, adv) for n, (g, adv) in glyphs_geom.items()}

# --- assemble TTF ---
fb = FontBuilder(UPM, isTTF=True)
order = [".notdef", "forall", "exists", "allsome"]
fb.setupGlyphOrder(order)
fb.setupCharacterMap({0x2200: "forall", 0x2203: "exists", 0xE900: "allsome"})

glyf = {}
pen = TTGlyphPen(None); glyf[".notdef"] = pen.glyph()
metrics = {".notdef": (600, 0)}
for name in ("forall", "exists", "allsome"):
    rings, adv, lsb = placed[name]
    pen = TTGlyphPen(None)
    for r in rings:
        pen.moveTo(r[0])
        for pt in r[1:]:
            pen.lineTo(pt)
        pen.closePath()
    glyf[name] = pen.glyph()
    metrics[name] = (adv, lsb)

fb.setupGlyf(glyf)
fb.setupHorizontalMetrics(metrics)
fb.setupHorizontalHeader(ascent=800, descent=-200)
VERSION = "1.0"
PUBLISHED = "2026-07-12"
ESSAY_URL = "https://dwheeler.com/essays/allsome.html"

# There is no standard name ID for a publication date, so it goes in the
# unique identifier (ID 3) and the description (ID 10), which is where such
# information conventionally lives.
fb.setupNameTable({
    "familyName": "Allsome",
    "styleName": "Regular",
    "psName": "Allsome-Regular",
    "fullName": "Allsome Regular",
    "uniqueFontIdentifier": f"David A. Wheeler: Allsome Regular: {PUBLISHED}",
    "version": f"Version {VERSION}",
    "designer": "David A. Wheeler",
    "manufacturer": "David A. Wheeler",
    "designerURL": "https://dwheeler.com",
    "vendorURL": ESSAY_URL,
    "description": ("The allsome quantifier: a font whose liga feature renders an "
                    "adjacent U+2200 FOR ALL and U+2203 THERE EXISTS as a single "
                    f"merged glyph. Published {PUBLISHED}. See {ESSAY_URL}"),
    "sampleText": "∀∃",
    "copyright": ("To the extent possible under law, the author has waived all "
                  "copyright and related or neighboring rights to the Allsome "
                  "font (CC0 1.0 Universal Public Domain Dedication)."),
    "licenseDescription": ("This font is dedicated to the public domain under the "
                           "Creative Commons CC0 1.0 Universal Public Domain "
                           "Dedication. No rights reserved."),
    "licenseInfoURL": "https://creativecommons.org/publicdomain/zero/1.0/",
})
# fsType=0 is "Installable Embedding": no embedding restrictions whatsoever.
# Anything else would contradict the CC0 dedication above. The default is 4
# ("Preview & Print"), which forbids recipients from installing the font.
fb.setupOS2(sTypoAscender=800, sTypoDescender=-200, usWinAscent=800, usWinDescent=200,
            achVendID="DAW ", fsType=0)
fb.setupPost()

addOpenTypeFeaturesFromString(fb.font, """
languagesystem DFLT dflt;
languagesystem latn dflt;
feature liga { sub forall exists by allsome; } liga;
""")

fb.font.save(TTF)
f = TTFont(TTF); f.flavor = "woff2"; f.save(WOFF2)

# --- verification raster: forall, exists, merged, side by side ---
# Written to a temporary directory; these are build check images, not artifacts.
import os, tempfile
SCR = os.environ.get("ALLSOME_BUILD_SCRATCH", tempfile.mkdtemp(prefix="allsome-build-")) + "/"
scale_px = 0.28
gap = 40
def render(names):
    imgs = []
    for n in names:
        g = glyphs_geom[n][0]
        b = g.bounds
        w = int((b[2]-b[0])*S*scale_px)+20; h = int(CAPH*S/ S *scale_px)+20
        h = int(1.5*CAPH*scale_px)+20
        im = Image.new("RGB", (max(w,30), h), "white"); d = ImageDraw.Draw(im)
        polys = list(g.geoms) if g.geom_type=="MultiPolygon" else [g]
        def T(x,y): return (10+(x-b[0])*S*scale_px, h-10-(y*S)*scale_px)
        for p in polys: d.polygon([T(*pt) for pt in p.exterior.coords], fill="black")
        for p in polys:
            for hl in p.interiors: d.polygon([T(*pt) for pt in hl.coords], fill="white")
        imgs.append(im)
    W = sum(i.width for i in imgs)+gap*(len(imgs)-1); H=max(i.height for i in imgs)
    strip = Image.new("RGB",(W,H),"white"); x=0
    for i in imgs: strip.paste(i,(x,0)); x+=i.width+gap
    return strip
render(["forall","exists","allsome"]).save(SCR+"allsome_a2_check.png")

print("allsome.ttf  ", TTF.stat().st_size, "bytes")
print("allsome.woff2", WOFF2.stat().st_size, "bytes")
print("metrics:", metrics)
