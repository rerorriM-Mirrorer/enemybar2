# enemybar2

Native FFXI target, subtarget, focus and aggro health bars for Windower4. Current test build: **Batch14, 1.1.1-a.20261018.14**. Read `TESTING.md` first for installation, current checks and the cumulative test record.

The complete install contains no `data` directory. Overlay its `enemybar2` folder onto the installed addon and reload. Saved settings take precedence; new defaults resolve the supplied `settings(20261017-053248).xml` globals plus Franklet overrides. New positions are computed relative to the client screen; literal uploaded coordinates and character names are not baked in.

## Start here

```text
//lua reload enemybar2
//eb defaults animations
//eb preview hp 5
//eb preview ghost
//eb preview kill
//eb preview heal
//eb preview spark
```

`defaults animations` is an explicit opt-in for existing characters, useful for trying the new preset on Cioara. It replaces animation/timing/effect/trail-color settings for the main bar, retaining positions, widths, font and other layout/visibility choices. Append `all` to apply each frame's own defaults to all four groups. Omit this command to retain your saved experiments. A reload alone merges missing settings without replacing existing values.

Commands take values first, then optional `t`, `st`, `ft`, `a`, or `all`; default is `t`. Numeric, color and style commands report settings when their value is omitted. Switches toggle when entered bare; explicit on/off is idempotent. Legacy `//eb set <setting> <bar> <values>` and frame-first shorthand remain supported.

| Everyday command | Behavior |
| --- | --- |
| `//eb` / `//eb help [topic]` | BattleStations-style chat-only help; bare and unknown commands show help. Topics: general, flash, ghost, underbar, shake, timing, layout, appearance, all. |
| `//eb status` | Version, layout, switches, timings and animation controls. |
| `//eb restart` | Dispose previews, detached ghosts and live bars, then dispatch one reload. |
| `//eb unload` | Same cleanup, then dispatch one unload. |
| `//eb defaults animations [bar]` | Apply the baked animation preset explicitly. |
| `//eb preview hp <1..100> [bar]` | Present chosen HP for8s; exposed-trail glow lasts through the configured hold/slide. |
| `//eb preview ghost [bar]` | Demonstrate a large loss with the selected bar's saved ghost settings. |
| `//eb preview kill [bar]` | Demonstrate a20%->0% finishing ghost with proportionally smaller glow/flares. |
| `//eb preview heal [bar]` | Demonstrate35%->85% recovery; extra glow/flares appear on main only. |
| `//eb preview spark [bar]` | Demonstrate the death glint without a detached ghost; forces sparkle on for this preview only. |
| `//eb preview off` | Close the demonstration; detached ghosts finish naturally. |

The new main preset uses a400px configured width, .1s foreground/underbar clocks, full trail opacity,2s trail hold/.5s slide,1.2s numeric counting and classic shake with both settling stages. Its ghost has alpha100, no contact/hover/lift distance, .9s lift phase and1s final fade with1px downward/1px right drift. Glow maximum extension33px, flare extension60px/width33px; underbar glow alpha50/extension33px, flare alpha78/extension45px/width30px. Existing Lionstag/Cioara saves remain their own until explicitly changed.

## Critical foreground and red pulse

From50% downward the red underbar smoothly pulses between its normal and brighter red; it never switches to white below10%. Its opacity still increases linearly as HP falls, unless the saved base trail alpha already equals full opacity. Healing retains its green/white feedback priority. At10% and below, the foreground sharply alternates normal fill and a neutral silhouette tinted with the chosen flash color/opacity.

| Command after `//eb` | Main preset / behavior |
| --- | --- |
| `foreground_period <seconds> [bar]` | .1; full cycle, half normal and half alternate state. Range.02..10. |
| `foreground_flash_color <r> <g> <b> [bar]` |255255255; channels are integers0..255. Neutral textures avoid the native fill's cyan cast. |
| `foreground_flash_alpha <0..255> [bar]` |0: pink/off.255: full-opacity flash. Multiplied by the frame's overall opacity. |
| `underbar_period <seconds> [bar]` |.1; independent red pulse clock, range.02..10. |
| `pulse_period <seconds> [bar]` | Shortcut setting both clocks together. |
| `low_hp_pulse [on/off] [bar]` | Toggle both low-health effects. |

For white flashing: `//eb foreground_flash_color 255 255 255`, then `//eb foreground_flash_alpha 255`. For pink/off: set alpha0. A softer alternate example is RGB255205220 with alpha160. Reissue `//eb preview hp 5` to compare.

## Detached ghost: movement, color and flickering height

Ghosts trigger on an **observed loss of at least75 HP percentage points, or any observed positive-HP->0% transition** while that bar is visible and `ghost_hit` is enabled. Repeated zero updates do not create another ghost; a large killing hit creates one chunk. Small finishing chunks copy only the remaining HP section, with proportionally smaller glow/flare height and capped flare width. Existing large ghosts retain their sizes. The addon needs to observe0%; target disappearance alone does not establish death. Such a sample may combine updates; the addon does not label it as a proven individual attack. Snapshots retain their tuning and screen position across target changes, live-bar recreation and preview replacement. Scene transitions/unload clean them up.

| Command after `//eb` | Default / meaning |
| --- | --- |
| `ghost_fade_to <white\|trail> [bar]` |white: stay white through opacity fade; trail restores the previous white-to-red transition. Affects the chunk; glow RGB remains separately controlled. |
| `ghost_height_mode <off\|snap\|smooth> [bar]` |snap: held short/tall jumps on the opacity clock; smooth follows its cosine wave; off restores steady height apart from contraction. |
| `ghost_height_min <0..1> [bar]` |.35: minimum fraction of the current glow/flare extension. Existing height settings are the maxima. |
| `ghost_height_strength <0..1> [bar]` |1: full modulation;0 disables height variation. |
| `ghost_glow_flicker [on/off] [bar]` |on: glow/flare opacity follows chunk flicker; off restores steady glow opacity. |
| `ghost_period <seconds> [bar]` |.1 full opacity cycle;0 disables opacity flicker and holds height at full size. Contact stays solid. |
| `ghost_alpha <0..255> [bar]` | Main100. Limits chunk and glow/flare opacity together. |
| `ghost_glow [on/off] [bar]` | Toggle middle glow and both edge flares. |
| `ghost_glow_color <r> <g> <b> [bar]` |24076100; edges use a paler version. |
| `ghost_glow_alpha <0..255> [bar]` | Main255. |
| `ghost_flare_alpha <0..255> [bar]` | Main200. |
| `ghost_glow_height <pixels> [bar]` | Main33; extra reach above/below the9px foot. |
| `ghost_flare_height <pixels> [bar]` | Main60; extra upward reach. |
| `ghost_flare_width <pixels> [bar]` | Main33; each edge's width. |
| `ghost_glow_duration <seconds> [bar]` | Main10; vertical contraction, bounded by the entire ghost lifetime. |

Movement commands remain `ghost_lift_up`, `ghost_lift_right`, `ghost_drift_up`, `ghost_drift_right` (signed pixels,-100..100). Negative up values travel down. Timing commands remain `ghost_contact_duration`, `ghost_lift_duration`, `ghost_hover_duration` (0..10s), and `ghost_fade_duration` (.01..10s). Glow/flare sizes accept0..100px; alpha values are integers.

To reproduce the previous rendering style, combine `ghost_fade_to trail`, `ghost_height_mode off`, and `ghost_glow_flicker off`. All can be compared independently.

## Main-bar recovery glow

Healing adds a soft green halo over the exposed recovery interval, a white flare at the advancing foreground edge and a pale green flare at the destination. Both ends follow the shrinking interval as the fill catches up; height, width and opacity settle with it. The ornaments use the existing `heal_duration` and `healing_effect` switch. They appear only on the main native FFXI bar, including its healing preview. Secondary/focus/aggro bars retain their earlier recovery behavior.

| Command after `//eb` | Default / meaning |
| --- | --- |
| `healing_glow [on/off]` |on; toggle the main recovery halo and flares together. |
| `healing_glow_alpha <0..255>` |160; halo opacity, multiplied by bar opacity and recovery fade. |
| `healing_glow_height <0..100>` |12; maximum extension above/below the interval, pixels. |
| `healing_flare_alpha <0..255>` |230; flare opacity. |
| `healing_flare_height <0..100>` |24; maximum upward extension, pixels. |
| `healing_flare_width <0..100>` |6; maximum width, capped for tiny recovery intervals. |

Use `//eb preview heal` after changing tuning. `//eb heal_duration .6` slows the recovery for comparison; existing saves keep their configured duration. Setting the duration to0 snaps recovery and produces no transient ornament. Damage, identity changes, hide, scene transitions and destruction hide or release these images.

## Closing death sparkle

Every observed positive-HP->0% transition on a visible native bar can schedule one small white/gold glint at its unshaken left closing endpoint. It uses BarFiller2's actual horizontal/vertical gain-sparkle arm textures, unchanged. The long horizontal ray and shorter vertical ray bloom once and fade, independently of the finishing ghost. With an animated damage trail, the glint starts after its.15s collapse; without that trail, it starts immediately.

It defaults on for every native bar role and remains independent of `ghost_hit`. Hide, aggro-row reflow, target switching and gauge recreation preserve its captured position and scalar settings; scene transitions and lifecycle cleanup cancel it. Repeated0% updates do not duplicate it. `//eb preview spark` isolates the glint; `//eb preview kill` combines it with the finishing ghost when the sparkle is enabled. Both previews show a20%->0% transition.

| Command after `//eb` | Default / meaning |
| --- | --- |
| `death_spark [on/off] [bar]` |on; bare toggles. `death_spark off all` disables every role. |
| `death_spark_alpha <0..255> [bar]` |230; multiplied by the bar's overall alpha.0 suppresses it. |
| `death_spark_size <2..64> [bar]` |16; maximum horizontal length in pixels; vertical length is75% of this. |
| `death_spark_duration <.05..2> [bar]` |.2s; glint lifetime after the trail closes. |

The sparkle-only preview forces the switch on locally but retains configured alpha/size/duration. It does not save that override. No sparkle can be inferred from disappearance if0% was never observed. Asset provenance is recorded in `assets/ffxi/README.md`.

## Exposed underbar: proportional size

The glow spans the exposed red interval from current HP edge to delayed trail edge. It is drawn above the red trail and below the live foreground. Both edges stay stationary during shakes, follow new damage/dragging/width changes, and converge as the red trail catches up. Decorations hide when the exposed interval reaches zero, during green healing feedback, or with the bar.

| Command after `//eb` | Default / meaning |
| --- | --- |
| `underbar_glow [on/off] [bar]` |on; toggles glow and both flares. |
| `underbar_size_mode <fixed\|scaled> [bar]` |scaled; fixed restores the previous maximum-size decoration. |
| `underbar_size_reference <1..100> [bar]` |25: percent of inner gauge width exposed where full size is reached. |
| `underbar_glow_height <pixels> [bar]` | Main33; maximum extra middle reach above/below the foot. |
| `underbar_flare_height <pixels> [bar]` | Main45; maximum upward extension. |
| `underbar_flare_width <pixels> [bar]` | Main30; maximum edge width. |
| `underbar_glow_min_height <pixels> [bar]` |2; minimum extra middle reach. |
| `underbar_flare_min_height <pixels> [bar]` |4; minimum upward flare reach. |
| `underbar_flare_min_width <pixels> [bar]` |1; minimum width, subject to available space. |
| `underbar_height_curve <0.1..4> [bar]` |.5; below1 keeps taller wisps as width shrinks;1 is linear. |
| `underbar_width_curve <0.1..4> [bar]` |1; width scales linearly. |
| `underbar_glow_alpha <0..255> [bar]` | Main50; middle opacity, limited by trail opacity. |
| `underbar_flare_alpha <0..255> [bar]` | Main78; edge opacity, limited by trail opacity. |
| `trail_alpha <0..255> [bar]` | Main255; baseline trail opacity. |
| `trail_color <r> <g> <b> [bar]` |1675796; preserves the separately saved alpha. |

Minimum sizes are capped at their configured maxima. Flare width is also capped at half the actual exposed interval to avoid excessively overlapping edges. At zero width everything hides rather than leaving a minimum-size orphan. Alpha and red pulse behavior remain independent of size. Reference size uses a fraction of bar width; heights remain UI pixels for comparison on different client resolutions.

## Shake and timing

The supplied main preset chooses `shake_style classic` and `super_settle both`. Main saved impact-only `shake_hold 10` and `shake_super_px 1` are retained in the new defaults but do not affect classic mode. Other frames use impact mode. Switch with `//eb shake_style impact` to test the decreasing impulse sequence.

Impact controls: `shake_small_px`, `shake_large_px`, `shake_super_px` (0..100px); `shake_hold` (0..10s), `shake_step` (.001..10s), `shake_rebound` (0..2), `shake_decay` (0..1), `shake_horizontal` (-2..2). `super_settle off/small/both` controls the weaker aftermath. All shakes use held integer jumps; text and red trail remain still.

Shared animation commands: `animation_duration`, `trail_delay`, `trail_duration`, `heal_duration`, `text_duration` (seconds0..10); switches `damage_trail`, `healing_effect`, `text_effect`, `hit_shake`, `low_hp_pulse`, `ghost_hit`. Damage restarts the trail hold from its current edge. Zero HP collapses the trail in.15s; main briefly retains0%, while dead aggro entries disappear immediately.

## Position, grid reminder and appearance

`//eb setup` shows guides and permits individual group dragging. `//eb setup all` drags the full arrangement together; `setup st` restricts dragging to subtarget. `edit` and `move` are aliases. Setup feedback and `//eb help layout` remind you about the grid.

**Hold either Ctrl key while dragging to snap the dragged group's anchor to a10px grid.** Release Ctrl for free movement; release the mouse to save positions. In setup-all mode the arrangement keeps its relative offsets; it does not snap every element separately. At a client boundary, bounds recovery can take priority over the grid.

Other layout commands: `pos <x> <y> [bar]`, `resetpos [bar]`, `lock/unlock [bar]` (default all), `bounds [on/off] [bar]`, `stack [up/down]` (bare toggles), `spacing <pixels>` (aggro), `count <1..32> a`.

Appearance commands: `width <pixels>`, `color <r> <g> <b>`, `background_alpha <0..255>`, `font "name"`, `fontsize <size>`, `bold`, `italic`, `show`, `hide`, `skin ffxi/classic`, `targetof`, `targeticon`, `action`, `distance`, `debuffs` with the usual optional bar/on-off forms. `ft [name/id/clear]` pins focus. Animation overlays require the native ffxi renderer; status-effect correctness review remains deferred.

## Verification and design notes

Run all seven `tests/*_spec.lua` files under Lua5.1 from the repository root. Suites cover motion, rendering geometry, commands, dynamic curves/tint, recovery/death, detached glint timing/cleanup, and the real entry point with mocked client/rendering dependencies. They do not establish live Windower texture filtering, frame cadence or visual feel.

`WORKFLOW.md` was read directly from GitHub and compared with NPCMirror's canonical copy: identical blob `bc17a173c779a7b921aed1d4bf8c539368aa3730`. Shared formatting uses fragment colors140/167/200/207/0 via Windower chat; help is not echoed to the console. See `docs/ANIMATION.md` for references and `docs/DESIGN-NOTES.md` for proposed future refinements, kept separate from delivered behavior.

## Cumulative changelog

- **2026-10-18 / Batch14:** Closing death glint using BarFiller2's unchanged gain-sparkle arm sprites; independent snapshot/lifetime, trail-close timing, per-role switch and size/alpha/duration controls, isolated sparkle preview. Retains Batch13 finishing ghosts and main healing effects.

- **2026-10-18 / Batch13:** Ghosts on all observed killing hits alongside the75-point trigger; small finishing ghosts have scaled glow/flares. Main-only green recovery halo and white/pale-green edge flares, tunable dimensions/alpha, and dedicated kill/heal previews. Existing settings remain authoritative.

- **2026-10-17 / Batch12:** Latest supplied preset as new defaults; opt-in animation preset adoption; adjustable foreground flash RGB/alpha; white/trail ghost fade; phase-linked ghost height/opacity; proportional underbar size; formatted help/topics; idempotent restart/unload cleanup and Ctrl-grid reminders.

- **2026-10-17 / Batch 11 hotfix:** Fixed HP preview without an explicit bar argument, added preview confirmation, moved the underbar glow above its trail and bounded it to the exposed damage interval. Brighter red glow/flare tints improve separation from the red fill; all saved tuning retained.
- **2026-10-17 / Batch 10:** Optional small underbar glow and endpoint flares with independent size/alpha controls; red-only pulse through critical HP; constant-opacity normal/white critical foreground; chosen-HP preview. Ghost threshold and saved tuning preserved.
- **2026-10-08 / Batch 1:** Delayed red damage trail with interruption handling; live dragging and locks; whole-layout/individual setup; optional bounds and resolution recovery; center-screen reset; shorter commands; native TP-blue subtarget and pink focus; bold/italic controls and status. Added shared development documents and root testing record.
- **2026-10-07 / .4:** UI-aware default positions and resetpos recovery.
- **2026-10-07 / .3:** 50%-opaque empty trough, native green aggro stack, primary-target exclusion, and .18-second HP slide.
- **2026-10-07 / .2:** Actual native DAT slices and load-size recovery, confirmed visually by user.
- **2026-10-08 / Batch 2:** Healing underlay/white growth; name and percentage color/count transitions; interruption handling; strict large-drop shakes; low-HP color/opacity pulses; individual switches and timing; reference study notes. Batch 1 package retained separately.

- **2026-10-08 / Batch 2 color comparison:** Healing text flashes brighter green (#35F264), sampled from the upper supplied swatch; timing and underbar tint retained.

- **2026-10-08 / Batch 3:** Basic setup restores individual dragging with all frames visible; explicit setup all moves arrangement. `//eb stack` toggles aggro direction; `stack up/down` sets it. Every damage hit nudges; text flashes red only for losses >=25 percentage points. Below25% fill fades toward white/transparency; below10% pink blinks sharply on/off (half of the 1.4-second period per state). Red underbar strengthens from50% HP toward configured overall opacity near zero, controlled with low_hp_pulse. `//eb trail_alpha 166 all` tries65% base trail opacity;128 restores50%. Healing text uses brighter #35F264.


### 2026-10-10 — Batch 4 (`1.1.1-a.20261010.4`)

- Optional `ghost_hit` overlays on observed losses >75 percentage points: pale flash, red return,4px lift and.35-second fade. They finish independently across target switches and gauge recreation.
- ZeroHP cancels trail holding and collapses the trail in.15 seconds. Dead aggro entries are displayed for at most1 second after observation.
- Red opacity scales across100–0% HP; red color brightens steadily across50–10%, then pulses below10%. Foreground critical blinking retains25% minimum opacity. Default full cycle.3 seconds; saved periods remain.
- Short feature aliases: `targetof`, `targeticon`, `action`, `distance`, `debuffs`; omit state to toggle. `show/hide [bar]`, `fontsize <size> [bar]`, `spacing <pixels>` for aggro. Bare value commands report settings. Short `stack` always affects aggro. Old setting syntax remains compatible.
- Action-message parsing is restricted to incoming0x029; expiry cleanup iterates sparse debuff keys correctly. Bind rules and boundaries are unchanged.
- Current test checklist appears first in TESTING.md; earlier records remain below it.


### 2026-10-11 — Batch 5 (`1.1.1-a.20261011.5`)

- Ghost loss threshold now includes75 percentage points. White copy appears immediately, lifts12px in.2s, hovers until1s, then drifts10px up/right and returns to red while fading through2s total. It is additional to the stationary damage trail. Ghost-enabled large hits use a stronger6/-8px shake over.3s.
- Foreground stays steady above10%. Red underbar pulses normal/brighter red at50–10%; at10% and below it pulses brighter red/white with sharp foreground100%/25% blinking. Saved pulse periods/alphas remain intact.
- Observed death accelerates numeric countdown to at most.15s and briefly displays0% after auto-detarget; a new target takes priority. Death trail still collapses in.15s. Ghosts finish independently.
- `edit`/`move` alias setup; help groups controls; status includes timings. `trail_color <r> <g> <b> [bar]` changes base RGB while preserving per-frame alpha. RGB/dimension validation added; existing command forms remain.


### 2026-10-12 — Batch 6 (`1.1.1-a.20261012.6`)

- Immediate removal of observed0HP aggro entries; main-target-only death hold. Capture a visible killing-hit ghost before compacting surviving aggro rows.
- Separate `foreground_period` (.25s) / `underbar_period` (.1s); `pulse_period` sets both. Existing shared saved periods seed missing split settings. New shared shortcut default.2s.
- Ghost tuning commands: `ghost_lift_up/right`, `ghost_drift_up/right`, `ghost_lift_duration`, `ghost_hover_duration`, `ghost_fade_duration`, `ghost_alpha`, `ghost_period`. Defaults6up/1right then9up/1right, .2s lift/.8s hover/1s fade, alpha255, .1s smooth flicker. ghost_period0 disables flicker. Each takes value then optionalbar; bare reports. Independent snapshots preserve animations during setting changes.
- `super_settle off/small/both [bar]` follows the super hit with no settling, small nudge, or medium then small; default small.
- `preview ghost [bar]` replays the configured ghost/trail/shake on a temporary demonstration; previewoff closes it, detached ghosts finish. Requires ffxi skin. Help/status/current tests cover new controls. Assets unchanged.


### 2026-10-12 — Batch 7 (`1.1.1-a.20261012.7`)

- All hit/settling shakes use immediate held-position jumps, preserving stage timing and random first direction. Ghost, fill and text transitions remain smooth.
- New-install defaults resolve the supplied settings(7).xml global+Franklet candidate, including compact widths, upward aggro stacking, opaque trail and main-target timing/ghost tuning. defaultPreset.lua records that preset; saved settings take precedence and default positions remain screen-relative.
- All animation commands/preview controls retained; no saved configuration shipped or modified.


### 2026-10-12 — Batch 8 (`1.1.1-a.20261012.8`)

- Shorten super-hit held offsets to.05s/.05s with.03s at rest before settling (.13s core). Small/both settling finishes at.25s/.43s. Ordinary hit shakes, ghost tuning, defaults and saved settings remain.


### 2026-10-13 — setup exit hotfix (`1.1.1-a.20261013.1`)

- Restrict the aggro killing-hit scan to numeric entity IDs. Closing setup no longer passes a placeholder label to get_mob_by_id or leaves guides visible after the draw aborts. Animation/settings behavior is preserved.


### 2026-10-13 — Batch 9 (`1.1.1-a.20261013.9`)

- Adjustable decreasing impact shake, with the previous style retained for comparison. Strengths, rebound/decay, first/later holds and optional horizontal component are configurable. Existing `super_settle` selects phase count in impact mode.
- Detached ghosts gain a solid white contact hold, soft contracting glow and bright edge flares. Color, alphas, heights, flare width and glow duration are exposed; existing trajectory and fade settings are preserved.
- Lua 5.1 deterministic tests cover motion, interruptions, snapshot ownership, renderer cleanup and actual command parsing. Live visual testing remains required.
- User reported all four clients successfully entering and exiting setup with the prior hotfix. Keep that numeric-ID guard. Status-effect review and Trust skin are deferred; distinct full-health finisher is a later experiment.
