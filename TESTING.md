# TESTING.md

This document belongs in the repository root and in development/testing packages. Private development and testing record.

## Current testing batch
- **Batch:** 2026-10-08 / Batch 1 — movement, native frame styles and delayed damage trail.
- **Package type:** Testing overlay, `enemybar2-ffxi-main-target-test.zip`; runtime files under `enemybar2/`, development documents at package root. Merge only `enemybar2/` into Windower/addons. No character settings are shipped.
- **Version:** `1.1.1-a.20261008.1`.
- **Status:** Offline checks pass; this batch awaits live FFXI testing. Existing native appearance has user-confirmed live results; new behavior does not yet.
- **Changes:** Always-draggable visible groups unless locked; optional bounds and runtime recovery on UI resolution changes; whole-layout dragging in setup/all, individual setup groups; shorter commands retaining legacy syntax; center-screen reset; native TP-blue subtarget and pink focus; bold/italic controls; delayed translucent red damage trail sampled from the supplied swatch, RGB 167/57/96, alpha 128.
- **Installation precautions:** Back up the installed addon and its `data` folder. Reload after merging files. Existing subtarget/focus skin and color are updated once to the requested presets, with a saved revision marker; subsequent customizations remain intact. Widths and saved positions are retained. Enabled bounds may recover an out-of-view position at runtime without saving it until you move/reset a frame.

## Live FFXI testing:
0. Reload with `//lua reload enemybar2`; run `//eb status` to verify `.20261008.1`. Confirm all four frame types retain native caps at load-in.
1. Use `//eb setup on`. Drag one bar: all frames should move together without losing their arrangement. Toggle off with `//eb setup off`.
2. Use `//eb setup st on`, then `//eb setup a on`: only that group should appear and move; aggro row spacing and stack direction should remain intact. Exit setup.
3. Drag a visible live bar without setup. `//eb lock` should prevent live dragging; `//eb unlock` restores it. Setup deliberately overrides locks. Ctrl-drag still snaps to the grid.
4. Try `//eb pos 300 400`, `//eb width 400`, and `//eb bold off all`; legacy `//eb set width t 400` should still work. `//eb italic off st` controls name italics separately.
5. With `//eb bounds on all`, drag toward every screen edge and try a smaller UI resolution. Gauge geometry should stay reachable. `//eb bounds off all` allows deliberate off-screen placement; `//eb resetpos` recovers main at screen center and `//eb resetpos all` centers the arrangement while preserving spacing. Oversized groups cannot fit fully; their size is retained and they are anchored at an edge. Long names and optional target/action text may extend past gauge bounds; exact text-edge clipping remains a follow-up.
6. Fight a target: the foreground should jump immediately on damage; a 50%-opaque red trail should hold for 1.5 seconds, then shrink over .45 seconds. Repeated hits restart the hold. A hit during shrinking freezes that edge and restarts the hold. Name/percentage still report actual HP immediately in this batch.
7. Switch between same-named enemies, clear/reselect a target, and observe aggro row reorder: trails must reset rather than transfer between monsters. Test zero HP, hide/show, reload, and drag while a trail is active. Healing currently uses the earlier simple fill slide and clears the damage trail.
8. Tune with `//eb trail_delay 1.5` and `//eb trail_duration .45`; `//eb damage_trail off` returns to the previous foreground-slide behavior. Repeat on Franklet and Lionstag at their different resolutions.

- **Next step:** Report visual timing and dragging results. Batch 2 will add healing growth, name/percentage transitions, configurable large-hit shakes and low-HP pulses after animation reference study. The below-2.5% effect is undecided. Main/master remains the earlier baseline until live testing earns promotion.

---

## Previous tests and checks
- **User-confirmed, 2026-10-07:** Revised native main bar loads correctly without dragging; user praised appearance. Green aggro stack appearance confirmed. Screenshot at 1280×720 shows setup layout. Existing .18-second HP motion described as nice on 2026-10-08.
- **User observation, 2026-10-07:** Off-screen saved main position on Franklet required editing global XML before setup dragging. This motivated resetpos and resolution recovery.
- **Offline, revision .4:** Geometry, deferred primitive-size reset, identity, aggro selection, settings commands, resetpos and cleanup passed with mocked Windower APIs under Lua 5.4. This does not verify game rendering or LuaJIT timing.
- **Offline, Batch 1:** Same regression suite extended for trail hold/restart/interrupt/completion, zero HP and identity reset; whole-layout and single-group mouse dragging; locks; shorter/legacy commands; text flags; UI recovery and disabled bounds. Nine runtime Lua files parsed with Lua 5.4; implementation uses Lua 5.1-compatible syntax. No live FFXI checks performed by Codex.

## Delivered packages and documents
| Date | Associated Batch | Item | Type | Commit / reference | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-10-07 | Native appearance revisions | enemybar2-ffxi-main-target-test.zip | Testing package | Chat: “That’s much better”; “I LOVE HOW THE BARS LOOK” | Actual native assets, load-size recovery, opacity, green aggro, initial HP slide. |
| 2026-10-07 | Revision .4 | Same package, updated | Testing package | Local commit `8464272`; chat: “I need that eeb resetpos” | Screen-aware defaults and resetpos; GitHub sync failed at delivery. |
| 2026-10-08 | Batch 1 | Same package; root development documents | Testing overlay | See branch Git history and version `.20261008.1` | First red-trail test, controls and styling. |

## User-provided materials, observations, and requests
| Date | Associated Batch | Item | Type | Commit / reference | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-10-07 | Native appearance | 51.DAT; HP MP BARS COOL.jpg | Uploaded references | Native atlas provenance in assets/ffxi/source/provenance.json | Source artwork and desired native appearance. |
| 2026-10-07 | Recovery | img_20261007_113853.jpg; settings(4).xml | Screenshot/settings | Chat: “On Franklet’s current lower resolution” | Screenshot 1280×720; width600 and aggro stack up. |
| 2026-10-08 | Batch 1 | trailingbarred.bmp | Uploaded swatch | Chat: “This red, please :)” | Dominant flat RGB 167/57/96; translucent trail requested. |
| 2026-10-07–08 | Batch 1 / 2 | Movement, styles and animation specification | Chat requests | “Maybe Enemybar2”; “When hit”; “And while healing” | Preserve staged delivery. Trail first; recovery/text, shakes and low-HP effects follow. |
| 2026-10-08 | Development conventions | NPCMirror root TESTING.md, DESIGN.md, WORKFLOW.md, AGATHOS.md | Repository references | NPCMirror/main fetched 2026-10-08 | Format and shared conventions adopted. Keep history; correct using strikethrough and explanatory notes rather than deleting. |
