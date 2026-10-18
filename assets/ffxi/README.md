These textures derive from `menu/gauge` in the supplied FFXI `51.DAT`. The game artwork belongs to Square Enix; extraction, the floating-gauge adaptation and renderer changes are by A. The original decoded 64 × 64 atlas and its source hash/crop coordinates are retained under `source/`. The complete DAT is not included or modified.

The trough endcaps are unchanged 4 × 8 pixel crops from atlas rectangles `(0,8,4,8)` and `(4,8,4,8)`, matching the HP/MP/TP composition in `framesus` group 8. They render at 6 × 12 pixels. The native 64 × 8 body at `(0,0)` supplies the three fill slices: 2/60/2 pixels wide, rendered at 9 pixels high. Only the middle stretches normally; tiny HP slivers compress their fill caps to stay within the actual HP fraction. The fixed outer caps keep their native shading and color.

The empty middle is the same body texture at low opacity over a near-black backing, so it can float over the world without needing a menu panel. The fill takes the configured resource tint. This is an adaptation of native texture pieces, not a claim to reproduce the client's dynamic rendering exactly.

`python tools/build_skin.py` rebuilds from the cached atlas; add `--dat /path/to/51.DAT` to repeat extraction from the supplied DAT. DAT block/image fields were checked against [FFXIDat BlockFile.h](https://github.com/XiyanFlowC/FFXIDat/blob/master/FFXIDat/BlockFile.h) and [Image.cpp](https://github.com/XiyanFlowC/FFXIDat/blob/master/FFXIDat/Image.cpp).


Batch 9 adds `ghost_glow.png` and `ghost_flare.png`: original procedural white/alpha gradients tinted at runtime. The middle has a symmetric vertical falloff; each flare narrows horizontally and grows brighter toward its foot. They are separate from the six unchanged native gauge slices.

`ghost_fill_left/mid/right.png` preserve the corresponding native fill alpha but use neutral white RGB, so the detached white flash has no cyan cast. Live fill/trough PNGs are untouched.

Batch14 reuses `sparkle_gain_arm_h.png` (33x9) and `sparkle_gain_arm_v.png` (9x33) unchanged from BarFiller2's `assets/slider/` in the supplied complete Grid Test3 package. These are the actual gain-sparkle arm sprites used by that addon's `trust_gauge.lua`, with a thin bright core and soft warm halo. They are independent of the FFXI atlas crops described above. Source package: `BarFiller2_CtrlDrag_Grid_Test3_Complete.zip`, Library identity `libfile_570d42b0b5288191a153a93acaa4be5a`. No image modification or DAT extraction was performed for the closing glint.
