# TESTING.md

This document belongs in the repository root and in development/testing packages. Private development and testing record.

## Current testing batch
- **Batch:** 2026-10-08 / Batch 2 — healing, text feedback, hit shakes and low-HP pulses.
- **Package type:** Separate testing overlay, `enemybar2-2026-10-08-batch-2.zip`. Contains Batch 1 controls plus additional animation; merge `enemybar2/` into Windower/addons. Development documents remain at package root; no saved settings are shipped.
- **Version:** `1.1.1-a.20261008.2`.
- **Status:** Offline regression and deterministic animation checks pass. No live result is claimed for either new batch. Batch 1 package remains unchanged for separate testing.
- **Changes:** Healing extends a green underlay immediately while the white foreground grows and returns to its configured tint. Name/percentage flash green for healing or the sampled red for damage and fade to semantic color; percentage counts from the displayed number. Damage interrupts healing. >25/>50 percentage-point HP drops shake caps/trough/foreground by the specified small/large sequence; the underlay stays stationary. Below25/below10 opacity/color pulses follow the specification. No extra below2.5 effect has been invented.
- **Installation precautions:** Back up installed addon/data. Test Batch 1 first if isolating the red trail; install Batch 2 afterward. To return to Batch 1, restore its runtime files. Extra unused Batch 2 modules can remain, but new settings will be ignored by Batch 1. Existing widths, colors, locks and layout settings remain; previously migrated subtarget/focus presets do not migrate again.
- **Reference study:** See `docs/ANIMATION.md` for links and the distinction between source findings and our design choices. Reviewed summaries/abstracts and a developer health UI walkthrough; embedded videos were not watched.

## Live FFXI testing:
0. Reload and verify `.20261008.2` using `//eb status`. Repeat the Batch 1 regression guide retained below.
1. Observe an enemy receiving healing or a focus target recovering HP: green underlay should extend immediately, with white foreground growing back to its resource tint over .35 seconds. No healing effect should be borrowed from a previous target ID.
2. Name/percentage should flash green during recovery and the sampled red on damage, fading to normal status color in .25 seconds. Percentage should count up/down in .22 seconds; a new change starts at the displayed number, including damage during healing. Supporting labels retain their usual color.
3. Test recovery interrupted by a hit: green/white should switch directly into red damage feedback, with a held damage trail and count-down. Repeated recovery updates should continue from the displayed fill/number. Text can temporarily lag actual HP by the configured short count duration.
4. Observe an HP drop >25 points and >50 points of maximum health: small nudge or larger 3/4-pixel sequence should return to the saved base position. The trail and name text stay stationary. Test near screen edges and drag during a shake; the base position must not drift. HPP samples can combine multiple attacks, so thresholds apply to observed updates.
5. Below25%, foreground opacity cycles 100–50% while red underneath brightens. Below10%, foreground shifts toward white while fading to zero, then returns. At zero, pulse stops. Clear/reselect and switch between same-named targets to verify reset. Below2.5% currently keeps the below10 behavior.
6. Individually disable using `//eb healing_effect off`, `//eb text_effect off`, `//eb hit_shake off`, `//eb low_hp_pulse off`; append `all` for every frame. Restore with on. Check disabled feedback stays disabled after reload.
7. Tune `//eb heal_duration .35`, `//eb text_duration .22`, `//eb pulse_period 1.4`. A zero text/heal duration snaps that transition; pulse_period must be >0. Run on Franklet and Lionstag and report whether the pulses/shakes fit FFXI's pace. Current font, bold/italic and semantic colors should remain correct.

- **Next step:** Collect separate Batch 1 and Batch 2 live results. Tune restrained timing/intensity and decide below2.5% behavior together. Exact optional-text bounds and visual asset filtering remain live follow-ups; do not promote untested work to main/master.

---

## Previous batch — Batch 1 (retained guide)
- **Batch:** 2026-10-08 / Batch 1 — movement, native frame styles and delayed damage trail.
- **Package type:** Testing overlay, `enemybar2-ffxi-main-target-test.zip`; runtime files under `enemybar2/`, development documents at package root. Merge only `enemybar2/` into Windower/addons. No character settings are shipped.
- **Version:** `1.1.1-a.20261008.1`.
- **Status:** Offline checks pass; this batch awaits live FFXI testing. Existing native appearance has user-confirmed live results; new behavior does not yet.
- **Changes:** Always-draggable visible groups unless locked; optional bounds and runtime recovery on UI resolution changes; whole-layout dragging in setup/all, individual setup groups; shorter commands retaining legacy syntax; center-screen reset; native TP-blue subtarget and pink focus; bold/italic controls; delayed translucent red damage trail sampled from the supplied swatch, RGB 167/57/96, alpha 128.
- **Installation precautions:** Back up the installed addon and its `data` folder. Reload after merging files. Existing subtarget/focus skin and color are updated once to the requested presets, with a saved revision marker; subsequent customizations remain intact. Widths and saved positions are retained. Enabled bounds may recover an out-of-view position at runtime without saving it until you move/reset a frame.

### Batch 1 live FFXI testing:
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
- **Offline, Batch 2:** Batch 1 suite plus deterministic recovery growth/tint, counting interruptions, name/percentage color restoration, strict shake thresholds, stationary underlay, low-HP opacity/color and reset/disabled-effect checks pass. Ten runtime Lua files parsed using Lua5.4; Lua5.1-compatible code, with live Windower/LuaJIT behavior pending. No new live results claimed.
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
| 2026-10-08 | Batch 2 | enemybar2-2026-10-08-batch-2.zip; docs/ANIMATION.md | Testing overlay/reference notes | See branch Git history and version `.20261008.2` | Separate package preserves Batch 1 for isolated tests. |

## User-provided materials, observations, and requests
| Date | Associated Batch | Item | Type | Commit / reference | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-10-07 | Native appearance | 51.DAT; HP MP BARS COOL.jpg | Uploaded references | Native atlas provenance in assets/ffxi/source/provenance.json | Source artwork and desired native appearance. |
| 2026-10-07 | Recovery | img_20261007_113853.jpg; settings(4).xml | Screenshot/settings | Chat: “On Franklet’s current lower resolution” | Screenshot 1280×720; width600 and aggro stack up. |
| 2026-10-08 | Batch 1 | trailingbarred.bmp | Uploaded swatch | Chat: “This red, please :)” | Dominant flat RGB 167/57/96; translucent trail requested. |
| 2026-10-07–08 | Batch 1 / 2 | Movement, styles and animation specification | Chat requests | “Maybe Enemybar2”; “When hit”; “And while healing” | Preserve staged delivery. Trail first; recovery/text, shakes and low-HP effects follow. |
| 2026-10-08 | Development conventions | NPCMirror root TESTING.md, DESIGN.md, WORKFLOW.md, AGATHOS.md | Repository references | NPCMirror/main fetched 2026-10-08 | Format and shared conventions adopted. Keep history; correct using strikethrough and explanatory notes rather than deleting. |
