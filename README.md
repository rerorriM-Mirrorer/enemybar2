# enemybar2

Native FFXI target, subtarget, focus and aggro health bars for Windower 4. Main/focus are pink, subtarget is TP blue and aggro is pale MP green. The current animation experiment is **Batch 11 hotfix, 1.1.1-a.20261017.11**. Start with `TESTING.md` for the current checks; the prior packages and observations are recorded below those checks.

Saved character positions, widths, colors, fonts and animation tuning take precedence over defaults. The package contains no `data` directory. New installs use the supplied Franklet preset with screen-relative positions: main near bottom center, subtarget/focus above it, aggro to the right. The same six native gauge slices are used for every bar.

## Everyday commands

Commands use values followed by an optional bar: `t`, `st`, `ft`, `a`, or `all`. Omit the bar to address main target. Original `//eb set <setting> <bar> <values>` and frame-first shorthand remain supported. Bare value commands report their current values. Feature switches support on/off and bare toggles.

| Command | Behavior |
| --- | --- |
| `//eb status` / `//eb help` | Version and configuration / command list. |
| `//eb setup [bar] [on/off]` | Show all guides; basic setup drags individual groups, `setup all` drags the arrangement, `setup st` restricts dragging to subtarget. Setup overrides locks. |
| `//eb edit` / `//eb move` | Setup aliases. |
| `//eb lock [bar]` / `//eb unlock [bar]` | Lock/unlock normal dragging; default all. |
| `//eb resetpos [bar]` | Centre and save main, selected group, or entire arrangement. |
| `//eb pos <x> <y> [bar]` | Set a position. |
| `//eb width <pixels> [bar]` | Gauge width. |
| `//eb show [bar]` / `//eb hide [bar]` | Display/hide a group. |
| `//eb stack [up/down]` | Aggro stack direction; bare toggles. |
| `//eb spacing <pixels>` / `//eb count <number> a` | Aggro spacing / maximum rows. |
| `//eb ft [name/id/clear]` | Pin a focus target; bare uses current target, `ft clear` removes it. |
| `//eb color <r> <g> <b> [bar]` | Fill tint, preserving alpha. |
| `//eb trail_color <r> <g> <b> [bar]` | Base red-trail tint, preserving trail alpha. |
| `//eb trail_alpha <0..255> [bar]` | Trail base opacity. |
| `//eb background_alpha <0..255> [bar]` | Trough opacity; default 128. |
| `//eb font "name" [bar]` / `//eb fontsize <size> [bar]` | Font / size; default Arial, bold and italic. |
| `//eb bold [on/off] [bar]` / `//eb italic [on/off] [bar]` | Text styling. |
| `//eb bounds [on/off] [bar]` | Keep gauge geometry within screen bounds. |
| `//eb targetof/targeticon/action/distance/debuffs [on/off] [bar]` | Optional labels/indicators. |
| `//eb skin ffxi/classic [bar]` | Native/current or original renderer. Ghost effects require ffxi. |

## Animation controls

Every row below is a command name after `//eb`. Append a bar to address it or `all` to change every bar; bare numeric/color/style commands report values. Saved values may differ from the listed defaults.

Damage snaps the native fill to the observed HP. The red trail holds, then slides; further damage restarts its hold from the current edge. Healing grows white fill back toward the configured tint with green text feedback. Red text flashes only for losses of at least 25 percentage points. From 50% HP downward the underbar pulses normal/brighter red, retaining those same colors below 10%. At 10% and below the foreground sharply alternates its normal tint and true white at constant configured opacity. Underbar opacity still strengthens linearly as HP falls; a saved trail alpha of 255 already makes it fully opaque. Zero HP cancels the trail hold and collapses it in .15 seconds; main briefly shows zero, while zero-HP aggro entries immediately disappear.

### Underbar glow and flares — Batch 10

Small versions of the ghost glow decorate the exposed red damage interval, between the shortened live HP edge and the delayed trail edge. The soft middle follows that interval's current width; flares track both its endpoints, including the held trail and its shrinking edge. The glow is drawn above the trail, below the foreground, using brighter red tints derived from the underbar pulse and its opacity. It remains stationary during shakes and hides when the trail catches up, with the bar, or during green healing feedback. It does not inherit the ghost's motion, flicker or lifetime. Existing ghost tuning and the **75-percentage-point-or-larger** trigger are unchanged.

| Command after `//eb` | New default | Meaning |
| --- | --- | --- |
| `underbar_glow [on/off] [bar]` | on | Toggle glow and both flares together. |
| `underbar_glow_alpha <0..255> [bar]` | 80 | Glow strength, multiplied by the underbar opacity; 0 hides only the middle. |
| `underbar_glow_height <0..100> [bar]` | 3 | Glow extension above and below the 9px underbar. |
| `underbar_flare_alpha <0..255> [bar]` | 140 | Flare strength, multiplied by underbar opacity; 0 hides only the flares. |
| `underbar_flare_height <0..100> [bar]` | 8 | Additional upward flare reach. |
| `underbar_flare_width <0..100> [bar]` | 3 | Each flare's width, capped on nearly empty bars; 0 hides flares. |
| `preview hp <1..100> [t/st/ft/a]` | — | Show chosen HP for 8 seconds, without a detached ghost. |

Try `//eb preview hp 50`, then `//eb preview hp 5` to compare the underbar and critical foreground. The exposed red interval and its glow are visible during the configured trail hold/slide; the HP demonstration remains for8s after the trail catches up. HP previews report their chosen percentage in chat. Use `//eb preview ghost` to compare your existing ghost beside the underbar glow. `//eb preview off` closes the demonstration. Numeric commands without values report settings; append `all` to tune every bar. For a more visible comparison, try glow alpha160/height6 and flare alpha220/height16/width6; these are optional values, not forced changes to saved settings. The supplied XML is a tuning reference, not bundled install data, and this batch does not replace existing defaults with Franklet's latest experiments.

### Impact shake — new controls

The new `impact` style uses one decreasing sequence of held integer offsets. Random direction reverses the whole sequence. Text and red trail stay stationary. Medium hits are losses greater than 50 percentage points; super hits require `ghost_hit` and a loss of at least 75 points. Small hits remain subtle.

| Command | New default | Meaning / accepted values |
| --- | --- | --- |
| `shake_style impact/classic` | impact | New decreasing rebounds, or the previous fixed sequences. |
| `shake_small_px <pixels>` | 1 | Initial ordinary-hit displacement, 0..100. |
| `shake_large_px <pixels>` | 4 | Initial medium-hit displacement, 0..100. |
| `shake_super_px <pixels>` | 8 | Initial super-hit displacement, 0..100. |
| `shake_hold <seconds>` | .05 | First displacement hold, 0..10. |
| `shake_step <seconds>` | .033333333 | Each later rebound hold, .001..10. |
| `shake_rebound <ratio>` | .5 | First rebound relative to the initial displacement, 0..2. |
| `shake_decay <ratio>` | .5 | Each subsequent rebound relative to the preceding one, 0..1. |
| `shake_horizontal <ratio>` | 0 | Horizontal displacement relative to vertical, -2..2; zero gives vertical only. |
| `super_settle off/small/both` | Saved choice; main both | Impact: 2/3/4 phases. Classic: prior no/small/medium-then-small settling. |

Impact `both` defaults to **8, -4, 2, -1, 0px** over .15 seconds, multiplied by random direction. `small` ends after the 2px correction at .1167s; `off` ends after the first rebound at .0833s. Rounding keeps every shake position on whole pixels. Impact strengths/timings do not modify the classic comparison sequence.

### Ghost contact, glow and edge flares — new controls

A loss of at least 75 percentage points captures an independent lost-section copy immediately. It remains solid white and stationary during contact, then follows the existing lift/hover/drift/flicker/fade settings. The soft glow contracts vertically and fades; two narrow edge flares follow the chunk. Its horizontal width continues to represent the lost section. Target changes, bar hiding/recreation and preview replacement let detached effects finish; zoning, cutscenes, logout and unloading clear them.

| Command | New default | Meaning / accepted values |
| --- | --- | --- |
| `ghost_contact_duration <seconds>` | .05 | Solid white hold before lift and flicker, 0..10; 0 restores immediate lift/flicker. |
| `ghost_glow [on/off]` | on | Both the soft glow and edge flares; bare toggles. |
| `ghost_glow_color <r> <g> <b>` | 240 76 100 | Glow tint, RGB integers 0..255; edges use a paler version. |
| `ghost_glow_alpha <alpha>` | 160 | Maximum glow opacity, integer 0..255. |
| `ghost_glow_height <pixels>` | 6 | Additional reach above and below the 9px chunk, 0..100. |
| `ghost_glow_duration <seconds>` | .4 | Glow contraction/fade after contact, 0..10; 0 hides glow. It ends no later than the chunk. |
| `ghost_flare_alpha <alpha>` | 230 | Maximum edge-flare opacity, integer 0..255; 0 hides flares. |
| `ghost_flare_height <pixels>` | 18 | Additional upward flare reach, 0..100. |
| `ghost_flare_width <pixels>` | 3 | Each edge's width, 0..100; 0 hides flares. |

The glow is steady rather than flickering. Opacity is also limited by the ghost's and frame's configured alpha. Setting `ghost_glow_alpha 0` leaves the edge flares; `ghost_flare_alpha 0` leaves the soft middle. The glow textures are neutral procedural gradients. Three white silhouettes preserve native alpha/shape without its cyan cast; Batch 10 also uses them for the critical foreground's white phase. The six original live bar assets are unchanged.

### Existing animation controls

| Commands | Meaning |
| --- | --- |
| `damage_trail`, `healing_effect`, `text_effect`, `hit_shake`, `low_hp_pulse`, `ghost_hit` | on/off; bare toggles. |
| `animation_duration`, `trail_delay`, `trail_duration`, `heal_duration`, `text_duration` | Seconds, 0..10. |
| `foreground_period`, `underbar_period` | Separate full-cycle periods, .02..10 seconds. |
| `pulse_period` | Shared shortcut sets both clocks, >0..10 seconds. |
| `ghost_lift_up`, `ghost_lift_right` | Initial movement in pixels, -100..100. |
| `ghost_drift_up`, `ghost_drift_right` | Additional movement during fade, -100..100. |
| `ghost_lift_duration`, `ghost_hover_duration` | Seconds, 0..10. |
| `ghost_fade_duration` | Seconds, .01..10. |
| `ghost_alpha` | Maximum chunk alpha, integer 0..255. |
| `ghost_period` | Flicker full-cycle seconds, 0..10; 0 disables flicker. |
| `preview ghost [t/st/ft/a]` / `preview off` | Demonstrate your current tuning / close demonstration. Detached chunks finish. |

For the main new-install preset, the existing ghost is 1px up/0 right in .1s, .3s hover, then 9px up/1 right over a 2.5s fade; the new .05s contact makes its total 2.95s. Other frames retain their .2s lift/.8s hover/1s fade, plus .05s contact. `ghost_glow_duration` is separate from these movement timings.

Compare the previous feel with `//eb shake_style classic`, `//eb ghost_glow off`, `//eb ghost_contact_duration 0`; restore `impact`, `on`, `.05` respectively. No special full-health finisher is added in this batch: 100→0 still uses the ghost effect, leaving a distinct finishing-hit experiment for a later pass. Status-effect correctness work and the alternate Trust skin are deferred.

Developers: run `lua5.1 tests/impact_spec.lua`, `lua5.1 tests/impact_commands_spec.lua` and `lua5.1 tests/underbar_spec.lua` from the repository root. These check motion, geometry, overlay ownership, commands, critical colors, preview modes and cleanup with mocked client dependencies. See `docs/ANIMATION.md` for primary-source references and the sequence of design decisions.

## Cumulative changelog

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
