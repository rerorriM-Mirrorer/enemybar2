"""Awake: extract menu/gauge from a supplied FFXI menu DAT and build slices.

    python tools/build_skin.py --dat /path/to/51.DAT

Without --dat, rebuild from the checked-in, unmodified gauge atlas.
Requires Pillow. The DAT itself is read only and is not included in the addon.
"""
from pathlib import Path
import argparse
import hashlib
import json
import struct

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "ffxi"
SOURCE = ASSETS / "source"


def extract(path):
    data = path.read_bytes()
    if data[:4] != b"menu":
        raise ValueError("Expected a menu DAT")
    offset = 32
    while offset + 16 <= len(data):
        header = struct.unpack_from("<I", data, offset + 4)[0]
        block_type = header & 0x7F
        size = ((header >> 7) & 0x7FFFF) * 16
        if block_type == 0:
            break
        if size < 16 or offset + size > len(data):
            raise ValueError("Invalid DAT block size")
        if block_type == 0x20 and data[offset+17:offset+33] == b"menu    gauge   ":
            version, width, height = struct.unpack_from("<III", data, offset+33)
            if data[offset+16] != 0xA1 or version != 40 or (width, height) != (64, 64):
                raise ValueError("Expected the native 64x64 DXT gauge texture")
            fourcc = data[offset+73:offset+77]
            length = struct.unpack_from("<I", data, offset+77)[0]
            if fourcc != b"1TXD" or length != 2048 or 85+length > size:
                raise ValueError("Expected the native DXT1 gauge payload")
            atlas = Image.frombytes("RGBA", (width, height),
                                    data[offset+85:offset+85+length], "bcn", 1)
            SOURCE.mkdir(parents=True, exist_ok=True)
            atlas.save(SOURCE / "menu-gauge.png")
            metadata = {
                "source_name": path.name,
                "source_sha256": hashlib.sha256(data).hexdigest(),
                "block_offset": hex(offset),
                "texture": "menu/gauge",
                "size": [width, height],
                "crops_xywh": {"body": [0, 0, 64, 8],
                               "left_cap": [0, 8, 4, 8], "right_cap": [4, 8, 4, 8]},
            }
            (SOURCE / "provenance.json").write_text(json.dumps(metadata, indent=2)+"\n")
            return atlas
        offset += size
    raise ValueError("menu/gauge was not found in this DAT")


def build(atlas):
    body = atlas.crop((0, 0, 64, 8))
    # Preserve native cap pixels and the body's horizontal/vertical shading.
    atlas.crop((0, 8, 4, 16)).save(ASSETS / "trough_left.png")
    atlas.crop((4, 8, 8, 16)).save(ASSETS / "trough_right.png")
    # The game places its translucent empty gauge over a menu background.
    # Give a floating enemy gauge its own dark backing under that texture.
    empty = ImageChops.multiply(body, Image.new("RGBA", body.size, (255, 255, 255, 48)))
    Image.alpha_composite(Image.new("RGBA", body.size, (12, 12, 16, 255)), empty).save(
        ASSETS / "trough_mid.png")
    body.crop((0, 0, 2, 8)).save(ASSETS / "fill_left.png")
    body.crop((2, 0, 62, 8)).save(ASSETS / "fill_mid.png")
    body.crop((62, 0, 64, 8)).save(ASSETS / "fill_right.png")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dat", type=Path)
    args = parser.parse_args()
    atlas = extract(args.dat) if args.dat else Image.open(SOURCE / "menu-gauge.png").convert("RGBA")
    build(atlas)
