"""Awake: reproducible vector sources and PNGs for the FFXI-inspired skin.

Run with Python 3 and Inkscape. These are original vector assets guided by
the supplied FFXI screenshot, not claimed to be extracted DAT textures.
"""
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "ffxi"
SOURCE = ASSETS / "source"
DEFS = '''<defs>
  <linearGradient id="rim" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#b6b3a8"/>
    <stop offset=".17" stop-color="#807e78"/>
    <stop offset=".45" stop-color="#55545a"/>
    <stop offset=".7" stop-color="#303038"/>
    <stop offset="1" stop-color="#777780"/>
  </linearGradient>
  <linearGradient id="well" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#08080c"/>
    <stop offset=".6" stop-color="#15151e"/>
    <stop offset="1" stop-color="#26262f"/>
  </linearGradient>
  <linearGradient id="fill" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#cecece"/>
    <stop offset=".17" stop-color="#ffffff"/>
    <stop offset=".35" stop-color="#eeeeee"/>
    <stop offset=".7" stop-color="#c8c8c8"/>
    <stop offset="1" stop-color="#959595"/>
  </linearGradient>
</defs>'''

CAP = '''
  <path d="M8 .5 H5 L.5 7 L5 13.5 H8Z" fill="#07070a"/>
  <path d="M8 1.5 H5.5 L1.5 7 L5.5 12.5 H8Z" fill="url(#rim)"/>
  <path d="M8 3 H6 L3 7 L6 11 H8Z" fill="url(#well)"/>
  <path d="M8 3.25 H6.1 L3.3 7" fill="none" stroke="#e4e0d7"
        stroke-opacity=".17" stroke-width=".5"/>
'''
MID = '''
  <path d="M0 .5 H8 V13.5 H0Z" fill="#07070a"/>
  <path d="M0 1.5 H8 V12.5 H0Z" fill="url(#rim)"/>
  <path d="M0 3 H8 V11 H0Z" fill="url(#well)"/>
  <path d="M0 3.25 H8" stroke="#e4e0d7" stroke-opacity=".17" stroke-width=".5"/>
'''
FILL_CAP = '''
  <path d="M4 0 H2 L0 3 L2 6 H4Z" fill="url(#fill)"/>
  <path d="M4 .5 H2.2 L.65 3" fill="none" stroke="#ffffff"
        stroke-opacity=".28" stroke-width=".5"/>
'''
FILL_MID = '''
  <path d="M0 0 H8 V6 H0Z" fill="url(#fill)"/>
  <path d="M0 .5 H8" stroke="#ffffff" stroke-opacity=".28" stroke-width=".5"/>
'''


def build():
    SOURCE.mkdir(parents=True, exist_ok=True)
    pieces = {
        "trough_left": (8, 14, CAP),
        "trough_mid": (8, 14, MID),
        "trough_right": (8, 14, '<g transform="translate(8 0) scale(-1 1)">'+CAP+'</g>'),
        "fill_left": (4, 6, FILL_CAP),
        "fill_mid": (8, 6, FILL_MID),
        "fill_right": (4, 6, '<g transform="translate(4 0) scale(-1 1)">'+FILL_CAP+'</g>'),
    }
    for name, (width, height, content) in pieces.items():
        source = SOURCE / (name + ".svg")
        source.write_text(
            '<svg xmlns="http://www.w3.org/2000/svg" '
            f'width="{width}" height="{height}" viewBox="0 0 {width} {height}">'
            + DEFS + content + '</svg>\n', encoding="utf-8")
        # Four source pixels per displayed pixel preserve the diagonal caps.
        subprocess.run([
            "inkscape", str(source), "--export-type=png",
            "--export-filename="+str(ASSETS / (name+".png")),
            "--export-width="+str(width*4),
            "--export-height="+str(height*4),
        ], check=True, capture_output=True)


if __name__ == "__main__":
    build()
