# TESTING.md

## Current tests — Batch 10 underbar glow and critical color flash (2026-10-17)

- **Repository / branch:** `rerorriM-Mirrorer/enemybar2`, `underbar-glow-2026-10-17`.
- **Baseline:** local Batch 9 package source, commit `83bee99`; current GitHub `master` AGENTS/WORKFLOW/TESTING read directly before editing. The animation branch had not previously been pushed. Current shared guidance was adopted in a separate commit; prior testing history below is retained.
- **Version:** `1.1.1-a.20261017.10`. Complete overlay install; merge the ZIP's `enemybar2` folder into `addons`, replacing matching files, then `//lua reload enemybar2`. No `data` folder or user XML is included.
- **Implementation commit:** `6356ff4`; shared-guidance adoption `4ef8646`. Both are local. Automatic approval review rejected the push to `origin` (`rerorriM-Mirrorer/enemybar2`) as an unverified publishing destination without authorization; no alternative publishing method was attempted. Delivery documentation is committed separately.
- **Requested behavior:** ghost remains triggered by observed losses >=75 HP percentage points; underbar pulses normal/brighter red from 50% downward, never switches to white; critical foreground alternates normal/white at <=10% while retaining opacity. Small underbar glow/flares follow its full width and both endpoints.
- **Available verification:** all Lua sources parse under Lua 5.1 via `lupa.lua51`; impact, command and underbar regressions pass with image/client mocks. These are offline checks, not live Windower or FFXI testing. Live filtering, perceived brightness and multiclient feel remain pending.

### Live comparison checklist

1. Reload and run `//eb status`: verify version .20261017.10, new underbar settings and your saved layout/ghost tuning. Enter/exit `//eb setup` on each client and confirm the prior placeholder-ID hotfix still holds.
2. `//eb preview hp 50`, then `//eb preview hp 5`. Each lasts 8 seconds. At <=50% the underbar stays normal/brighter red; at <=10% the foreground alternates normal/true white with no quarter-opacity phase. Compare `//eb preview hp 11` to confirm foreground stops flashing above 10%.
3. `//eb preview ghost`: compare the existing large ghost with the new smaller underbar glow. The underbar's right flare follows its held edge, then follows its shrinking edge; the left flare stays at the underbar's origin. Neither follows the hit-shake offset. Drag in setup and change width to check both endpoints follow the gauge.
4. Tune one value, then preview again: `//eb underbar_glow_height 3`, `//eb underbar_glow_alpha 80`, `//eb underbar_flare_height 8`, `//eb underbar_flare_width 3`, `//eb underbar_flare_alpha 140`. Values shown are the new defaults. Append `all` for all bars; omit numeric values to report. Size ranges 0..100; alpha must be integer 0..255.
5. `//eb underbar_glow off`, then `on` to compare. Glow alpha 0 removes only the soft middle; flare alpha or width 0 removes only the flares. Compare `//eb low_hp_pulse off` / `on` separately; it retains its established control over both low-health layers.
6. Verify healing suppresses the red glow during green healing feedback; target switching, hide, zero HP, setup exit, cutscenes and unload leave no persistent flares. Repeated previews replace the demonstration; detached ghosts still finish. Main retains its brief 0% hold; dead aggro bars disappear immediately.
7. Actual >=75-point HP losses should still produce ghosts; smaller losses should not. The offline renderer test covers 74-point versus exactly 75-point boundaries. The tentative 100%-kill-only restriction was superseded by the user's clarification; no threshold change was made.

### Supplied tuning reference and observations

- `settings(20261017-043401).xml`, uploaded 2026-10-16 in America/Chicago, was read from the supplied file. Franklet inherits global settings and overrides the main bar: foreground/underbar .1/.1s; ghost alpha100, no contact/hover/lift distance, .9s lift phase, -1px upward drift (1px down) / inherited1px right during1s fade; glow alpha255/height33/duration10; flare alpha200/height60/width33. Glow duration is capped by the ghost's lifetime. Classic shake remains selected; saved impact-only `shake_hold 10` and `shake_super_px 1` therefore do not affect classic shake. Positions and all saved tuning are preserved.
- Franklet's `trail_color.alpha=255` overrides the global128, so his trail is already fully opaque and only its color pulses. The same .1-second clocks apply independently, while `pulse_period` retains a separate older saved shortcut value.
- This XML was supplied as a visual reference, not a request to overwrite every frame's defaults. No user-specific positions or XML are shipped in the package. Existing defaults and ghost settings are unchanged; only the six new underbar settings are introduced.
- The previous attachment `settings(20261017-043127).xml` was XIVParty configuration, not an EnemyBar2 tuning source.
- Bind/debuff correctness review, Trust-style skin, distinct full-health finishing effect and bottom-centre-relative saved position controls remain outside this batch.

## Agent entry-point adoption — 2026-10-16

- Added [`AGENTS.md`](AGENTS.md) to direct repository-aware coding agents to read the current `WORKFLOW.md` and `TESTING.md` before making changes.
- **Commit:** [`23103ed`](https://github.com/rerorriM-Mirrorer/enemybar2/commit/23103edd4d769fd7bdaf3336fad4649e4dfe41ea).
- **Scope:** Documentation only; no addon code changed, testing ZIP generated, or in-game test performed.
- **Continuity:** Earlier testing and development records below remain intact.

## Package layout convention — 2026-10-16

- **Repository:** Keep `WORKFLOW.md` and `TESTING.md` at the repository root.
- **Testing ZIPs:** Include both inside the installable addon folder alongside the README and code. For patch/test-only bundles without an addon folder, place both next to the delivered files. No redundant outer ZIP-root copies.
- **Reference commit:** [`17983fb`](https://github.com/rerorriM-Mirrorer/enemybar2/commit/17983fb57b589311bc36702064ec0a993edffe03).
- **Verification:** Documentation only; no game code changed and no in-game tests performed for this instruction update.
- **History:** Previous ZIP-root conventions remain below as historical records, with dated corrections where they were stated as current instructions.

# Current tests — Batch 9 impact shake and ghost glow (2026-10-13)

1. Reload, then `//eb status`: **1.1.1-a.20261013.9**. Your saved positions, widths, trail color/alpha, pulse periods, text timing and ghost movement should remain.
2. Run `//eb preview ghost`. New defaults use `shake_style impact`, a .05s solid white ghost contact, and contracting glow with bright edge flares. With `super_settle both`, the shake jumps 8, -4, 2, -1, then centre over .15s; the random initial direction may reverse it. Red underbar and text stay still. Preview uses the selected bar's actual tuning.
3. Compare `//eb shake_style classic`, then `//eb shake_style impact`. Try `//eb super_settle off`, `small`, and `both` between previews. In impact mode these choose 2, 3 or 4 phases rather than restarting weaker sequences. Ordinary/medium hits use the same decreasing pattern at smaller strengths; check those during combat.
4. Tune examples, previewing after each: `//eb shake_super_px 10`, `//eb shake_hold .06`, `//eb shake_step .04`, `//eb shake_horizontal .25`. Reset to 8, .05, .033333333, 0 to compare. There is no tween between shake positions.
5. Compare `//eb ghost_glow off` / `on`; tune `//eb ghost_glow_alpha 200`, `//eb ghost_flare_height 12`, `//eb ghost_flare_width 4`, `//eb ghost_glow_duration .6`. Try `//eb ghost_glow_color 255 50 75`. `ghost_glow_alpha 0` hides only the middle, `ghost_flare_alpha 0` hides only edges. Re-preview to see updated snapshots.
6. Try `//eb ghost_contact_duration .1`, then .05; set 0 to restore immediate lift/flicker. Existing ghost lift/hover/fade begin after this contact hold, adding it to total duration. The glow duration starts after contact and is capped by the chunk's lifetime.
7. Append `st`, `ft`, `a` or `all` to any tuning command; omission means main target. Bare numeric/color/style commands report values; bare `ghost_glow` toggles. Original `set <setting> <bar> <values>` and frame-first shorthand remain. Try invalid style, negative duration, fractional alpha and unknown bar; settings should stay unchanged. Reload after tuning and verify persistence.
8. Repeated previews, `preview off`, clearing/switching targets and changing settings should leave detached chunks finishing at their original positions. Zoning, cutscene, logout and unload should clean up all glow/flare/chunk images. Watch multiple consecutive ghosts for lingering images.
9. Retest zero-HP aggro removal and main's brief zero display; healing interrupted by damage; independent foreground/underbar pulses; basic setup and `setup all` dragging; repeated setup exits on all four clients. A distinct 100%-kill finisher and Bind/debuff review are deferred.

## New tuning commands

All use `//eb <command> <value> [t/st/ft/a/all]`, except the RGB and on/off forms shown. See `enemybar2/README.md` for the full existing command list, accepted ranges and examples.

| Command | Default | Purpose |
| --- | --- | --- |
| `shake_style impact/classic` | impact | New decreasing sequence / previous shake. |
| `shake_small_px`, `shake_large_px`, `shake_super_px` | 1, 4, 8 | First displacement in pixels for each tier. |
| `shake_hold`, `shake_step` | .05, .033333333 | First hold / subsequent holds in seconds. |
| `shake_rebound`, `shake_decay` | .5, .5 | First rebound ratio / subsequent reduction ratio. |
| `shake_horizontal` | 0 | Horizontal component relative to vertical; negative reverses it. |
| `super_settle off/small/both` | Existing setting; main both | Impact phase count 2/3/4; prior meaning in classic mode. |
| `ghost_contact_duration` | .05 | Solid white stationary contact hold before lift/flicker. |
| `ghost_glow on/off` | on | Both glow and edge flares; bare toggles. |
| `ghost_glow_color <r> <g> <b>` | 240 76 100 | RGB tint; flares use a paler version. |
| `ghost_glow_alpha`, `ghost_flare_alpha` | 160, 230 | Separate maximum opacity, integers 0..255. |
| `ghost_glow_height` | 6 | Additional reach above and below the chunk, pixels. |
| `ghost_flare_height`, `ghost_flare_width` | 18, 3 | Additional upward reach / width, pixels. |
| `ghost_glow_duration` | .4 | Glow contraction/fade after contact, seconds. |

## Batch record and verification

- **Baseline:** exact `enemybar2-2026-10-13-setup-hotfix.zip` contents, version .20261013.1; restored as local commit `4e89c7c` because earlier local-only development history was unavailable in this workspace. Root workflow uses the already-consolidated repository document.
- **Contents:** complete runtime `enemybar2/` overlay, including two new procedural gradient assets and three neutral ghost silhouettes, three neutral ghost silhouettes and `ghostMotion.lua`; root `TESTING.md` and consolidated `WORKFLOW.md`; no saved `data/settings.xml`.
- **Offline:** Lua 5.1 parsing and deterministic motion/renderer/command tests passed. Exact phase boundaries, interruption, stationary underbar, independent snapshots, false toggles, zero durations, invalid arguments and complete cleanup are exercised. This does not establish Windower's live image filtering or final animation feel.
- **Prior live result:** user reports all four clients entered/exited setup without errors on the .20261013.1 hotfix. That is the observed setup result, not certification of every prior feature.
- **Current live result:** awaiting this batch's in-game comparison.
- **Animation commit:** `5fc8457` on `impact-glow-2026-10-13`; committed locally, not pushed. Documentation/package records are a separate commit.

---

## Previous tests and deliveries (preserved)

# Current tests — setup exit hotfix (2026-10-13)

1. Reload and check `//eb status` for **1.1.1-a.20261013.1**.
2. On Franklet, enter `//eb setup`, then close with `//eb setup off`. Repeat twice. No get_mob_by_id string/number error should appear; unneeded aggro guides must disappear.
3. Repeat with `//eb setup all` and `//eb setup st`. Exit and confirm real aggro entries resume correctly. Try `//eb preview ghost` and confirm the latest shake/ghost settings remain.

Root cause: setup rendering uses the label "Aggro Target Name" as its identity. The new killing-hit scan passed that string to get_mob_by_id after setup closed, aborting each draw before the guides could hide. The scan now looks up only numeric entity IDs; setup-label identities are cleared by normal live update/hide handling.

A regression reproduces two setup exits using a numeric-only API mock, checks hidden guides, then verifies live aggro resumes. Offline Lua5.4 parse and regression checks pass; live Windower testing remains pending. Saved settings and animation behavior remain unchanged.

---

## Previous batches (preserved)

# Current tests — Batch 8 quicker super-hit jolt

1. Reload; `//eb status` reports **1.1.1-a.20261012.8**. Run `//eb preview ghost` using your current settings.
2. Super-hit jumps now hold6px for.05s, opposite8px for.05s, then rest for.03s. Settling begins at.13s. Compare `super_settle off`, `small`, `both`: total shake durations.13s/.25s/.43s respectively. Starting direction remains random.
3. Confirm ordinary small/medium hits retain their prior timings, the red underbar stays still, and the ghost's configured lift/hover/fade/flicker are preserved. All tuning commands and saved settings remain.

Offline Lua5.4 parsing and regression checks pass, including exact super-hit phase boundaries and settling modes. Live Windower comparison remains pending. Full runtime overlay without saved configuration.

---

## Previous batches (preserved)

# Current tests — Batch 7 discrete shakes and Franklet defaults

1. Reload and check `//eb status` for **1.1.1-a.20261012.7**. Saved settings remain authoritative. Run `//eb preview ghost`; use `//eb super_settle both t`, `small`, or `off` to compare.
2. Every hit shake now jumps immediately to its offsets and holds them: small+1/-1/0 over.12s; medium+3/-4/0 over.18s; super+6/-8/0 over.30s. First direction remains random; no tweening between offsets. Super settling uses the same discrete medium/small phases. Red underbar/text stay stationary. Ghost lift/drift and HP/text transitions stay smooth.
3. Observe ordinary small hits, medium hits and a real superhit. Repeated damage restarts the appropriate shake. New target identity resets shake. Preview repeatedly, switch targets and reload after tuning. All Batch6 tuning commands remain available.
4. New-install defaults use settings(7).xml global values merged with Franklet overrides: main400px, sub200px, focus250px, aggro100px/sixrows/up/20px spacing; trail alpha255 allframes. Main animation_duration3, text_duration1.2, trail_delay2, trail_duration.5, show_diston, super_settleboth; ghost1px up/0right in.1s, .3s hover, 2.5s fade, inherited9px up/1right drift and.1s flicker. Main foreground/underbar periods.25/.25; otherframes.2/.2. Other fonts, tints and toggles resolve from the supplied globals. Positions stay screen-relative for new installs; installed saved positions remain.
5. Existing configurations are not overwritten by adopting new defaults. Verify Franklet's supplied positions and Lionstag's own settings remain after overlay/reload. This package contains no data/settings.xml. No animation command was removed.

## Verification and reference

Offline Lua5.4 parse and deterministic regressions pass: exact held offsets at boundaries/intermediate times, both starting directions, settling/interruptions, default preset values, plus prior renderer/preview/death/migration/tracking checks. Windower/Lua5.1 live comparison remains pending. User reports Batch6 preview looking excellent and supplied settings(7).xml as the current candidate; subsequent nudging is expected.

Reference: settings(7).xml uploaded2026-10-12, read directly from supplied attachment. Defaults resolve global+franklet fields; do not import literal screen positions or character names into runtime settings. The source attachment is unmodified.

---

## Previous batches (preserved)

# Current tests — Batch 6 tuning and ghost preview

1. Reload and confirm **1.1.1-a.20261012.6** with `//eb status`. Existing layout, colors, text duration and saved pulse timing should remain. User reported Batch5 working well and observed the ghost in-game; this does not certify every edge case. This batch passes offline tests and awaits live testing.
2. Try `//eb foreground_period 0.25 all` and `//eb underbar_period 0.1 all`. At10% and below, foreground sharply alternates100%/25% alpha on its own clock; underbar smoothly pulses brighter red/white on its separate clock. At50–above10%, foreground is steady and underbar pulses normal/brighter red. `//eb pulse_period 0.2 all` sets BOTH clocks. Bare individual commands report values. Old saved shared periods seed missing split clocks; new installs default.25/.1, and the shared shortcut defaults.2.
3. Kill aggro enemies: entries disappear on the draw update observing0HP and remaining rows close the gap. A previously visible killing-hit ghost still finishes. A live1HP enemy must remain. No death hold remains on aggro/subtarget/focus; only main retains its accelerated countdown and.65s total0HP display/auto-detarget hold.
4. Run `//eb preview ghost` (main), or `//eb preview ghost a`. Observe6px up/1px right in.2s, .8s hover, then9px up/1px right while fading and returning to red in1s. Ghost opacity flickers smoothly100–0–100 on a.1s full cycle, multiplied by the final fade. Red trail stays in place. Reissue preview to replace the demonstration; already-detached ghosts finish. Preview requires ffxi skin and is unavailable during cutscenes. `//eb preview off` closes the demonstration; detached ghosts finish normally.
5. Tune initial movement with `ghost_lift_up`, `ghost_lift_right`; additional fading movement with `ghost_drift_up`, `ghost_drift_right`. All accept pixel values (negative reverses direction), then optionalbar. E.g. `//eb ghost_lift_up 3 t`. Tune seconds with `ghost_lift_duration`, `ghost_hover_duration`, `ghost_fade_duration`. Lift/hover may be0; fade must be positive. Changing settings preserves existing ghost snapshots; rerun preview for the new values.
6. Tune `//eb ghost_alpha 180 t` for maximum opacity; `//eb ghost_period 0 t` disables flicker; `.1` restores it. Bare commands report values; `all` applies to allframes. Alpha0..255 integer, movement-100..100px, durations0..10s (fade.01..10), split periods.02..10s. Try invalid inputs and confirm settings are unchanged.
7. Compare `//eb super_settle small t` (default), `both`, and `off` using preview. Super6/-8/0px in.3s; small adds a1px nudge in.12s (.42s total); both adds3/-4/0px in.18s then1px in.12s (.60s total). With hit_shake off, no shake. Text and red underbar remain stationary.
8. Switch/clear targets or change settings during real ghosts. Reload after tuning and inspect status. Test previews repeatedly, zoning/cutscenes/logout/unload cleanup, healing interruption, main death hold, setup/edit/move dragging and locks. Existing assets and tracking rules remain; Bind review is separate.

## Commands and defaults

| Command | New default | Unit |
| --- | --- | --- |
| foreground_period | .25 | seconds/full cycle |
| underbar_period | .1 | seconds/full cycle |
| ghost_lift_up / ghost_lift_right | 6 / 1 | pixels |
| ghost_drift_up / ghost_drift_right | 9 / 1 | additional pixels |
| ghost_lift_duration / ghost_hover_duration / ghost_fade_duration | .2 / .8 / 1 | seconds |
| ghost_alpha | 255 | maximum alpha |
| ghost_period | .1 | seconds/full cycle;0 disables |
| super_settle | small | off/small/both |

Every tuning command accepts a value then optional t/st/ft/a/all; omission of the value reports it. Existing saved split clocks take precedence over migration. Preview uses configured appearance/motion, forces ghost_hit on for demonstration, and draws at the selected frame's current position.

## Verification

Offline Lua5.4 parsing; renderer/identity/commands/ghost lifetime/flicker, independent clocks, settling sequences, main death hold, immediate aggro removal, settings migration, repeatable preview cleanup and prior tracking regressions pass. No Lua5.1/Windower live execution is claimed. Complete runtime overlay without saved data/settings; root development guides included.

---

## Previous batches (preserved)

# Current tests — Batch 5 ghost, critical HP and death display

1. Reload; `//eb status` should report **1.1.1-a.20261011.5**, all animation timings and switches. Keep your installed layout/settings. Try `//eb text_duration 1 all`; use `//eb pulse_period 0.3 all` to compare the new default with your saved period.
2. Observe a loss of **75 percentage points or more**. A separate lost-segment copy immediately turns white at full configured bar opacity. It lifts12px in.2 seconds, eases into a white hover until1 second, then drifts another10px up/10px right, turns back to the base trail red and fades over the final second. Total2 seconds. Main trough/foreground shake6px one way,8px the other and return in.3 seconds; red trail stays stationary. `ghost_hit off` disables the ghost and its extra shake tier, retaining normal hit shakes.
3. Switch/clear targets during any ghost phase, or change a setting that recreates gauges: ghost stays at its original position and finishes. Multiple chunks can coexist. Zone/cutscene/logout/unload clears ghosts. Existing cap/body assets are unchanged; no Trust skin is included.
4. Between50% and above10%, only the red underbar smoothly pulses normal red/brighter red. Foreground stays its normal resource tint and opacity. At exactly10% and below, underbar pulses brighter red/white while foreground sharply alternates100%/25% opacity. Baseline underbar opacity still increases linearly across100–0% HP; healing takes priority until its transition ends.
5. Observe death with a long text duration. Remaining displayed HPP counts to0 in at most.15 seconds; foreground empties immediately and red trail collapses in.15 seconds. The observed dead target remains for.65 seconds total, including at least.5 seconds at0%. Auto-detarget preserves this short hold. Repeated0HP observations must not restart it. Selecting a different target replaces the death display immediately, without transferring its count/hold. Ghosts remain independent. No hold can be created if0HP was never observed.
6. Check aggro death/recovery/reordering. Dead entries still have the1-second maximum cap; displayed death holds end sooner. Missing entries may retain their own brief death display in an unused slot; reassigned slots immediately display the new identity. Explicit hiding, cutscenes and logout cancel the hold. Renderer recreation resets death holds.
7. `//eb edit on`, `//eb move all on`, `//eb move off` are setup aliases: basic individual drag versus explicitall arrangement drag is preserved. `//eb help` is grouped by purpose; `//eb status` includes timings. `//eb trail_color 167 57 96 t` sets base trail RGB and preserves trail_alpha. Bare `//eb trail_color all` reports RGB. Test your current saved alpha200 and other frame colors remain separate.
8. Invalid colors outside0..255/fractional RGB, width outside16..4096, font size outside1..72, aggro count outside1..32, or spacing outside0..4096 must report an error without modifying settings (dimension controls require integers). Old syntax and short aliases remain compatible. Test reload, healing interrupted by damage, small hits and setup modes.

## Batch record

- Offline Lua5.4 parsing and deterministic/mock regressions pass, including death countdown/hold, identity replacement, ghost geometry/lifetime, critical thresholds, command validation and prior packet/debuff fixes. Live Windower/Lua5.1 testing remains pending.
- Supersedes Batch4 animation details; previous records are preserved below. User preferred text_duration1 and requested a stronger two-second white ghost plus underbar-only pulsing above criticalHP. New default text_duration remains.22; saved experiments remain intact.
- Current assets retained. Boundaries and Bind/debuff removal rules remain unchanged.

---

## Previous batch and historical record

# Current tests — Batch 4 animation and controls

1. Reload and check `//eb status` for **1.1.1-a.20261010.4**. Confirm your existing layout, widths, fonts and baseline trail alpha remain.
2. Set `//eb pulse_period 0.3 all` to try the new default on existing saved settings. A full cycle lasts .3 seconds; critical foreground states each last .15 seconds. Existing saved periods are deliberately preserved on reload.
3. Watch the red underbar: opacity rises linearly from the configured baseline at100% HP to full bar opacity at0%. Between50% and10% its color steadily brightens with falling HP, without a color pulse. Below10% it smoothly pulses toward an even brighter red, while the foreground sharply alternates full/25% opacity. The10–25% foreground retains its smooth white fade, now with a25% opacity floor. Healing temporarily takes priority.
4. Test an observed HP drop **greater than75 percentage points**: the lost segment flashes pale pink-white, returns toward its red tint, lifts4px and fades over.35 seconds. Switch targets immediately: the detached chunk must finish at its original screen position. Try `//eb ghost_hit off all` / `//eb ghost_hit on all` for comparison. Normal target clearing and bar recreation preserve it; zoning, cutscenes, logout and unload clear it.
5. Kill a target during either the red hold or its slide. The foreground empties immediately and the trail starts racing to zero over.15 seconds. A ghost, if triggered, finishes independently. A0HP aggro entry must disappear within1 second even if its enmity record remains; recovering HP re-enables it.
6. Try `//eb targetof a` (toggle whom aggro enemies target), `//eb targetof off a`, `//eb action on t`, `//eb distance off all`, `//eb debuffs a`, and `//eb targeticon t`. `//eb show st` / `//eb hide st` control bar visibility. Legacy commands still work.
7. Try `//eb fontsize 11 st`, `//eb spacing 27`, `//eb stack up`, then bare `//eb stack`. Spacing and short stack commands affect aggro only. `//eb width`, `//eb pos st`, `//eb font all`, `//eb trail_alpha all` report current values. A toggle with `all` uses the inverse of the main bar's setting as one shared state.
8. Regression: `//eb setup on` shows all bars with individual dragging; `//eb setup all on` moves the arrangement; `//eb setup st on` limits dragging to subtarget. Test healing interrupted by damage, small-hit shake without red name flash, and large-hit shake. Boundaries and Bind behavior are unchanged.
9. Observe tracked debuffs wearing off/expiring during play. Offline checks verify unrelated packet IDs never enter action-message parsing and sparse status IDs receive expiry cleanup. No live packet capture or FFXI execution is claimed here.

## Batch record

- Offline Lua5.4 parsing and mocked renderer, lifecycle, command, animation, aggro and tracking regressions pass. Lua5.1/Windower live validation remains pending.
- Full runtime package, with no saved settings/data. Keep your installed configuration. No installation walkthrough is repeated.
- New default pulse period.3 seconds; baseline trail alpha default remains128 (your saved200/255 is retained). Brightening endpoints are RGB224/86/130 and255/130/160 for this test; the original red remains167/57/96.
- User reports Batch3 working very well and brighter healing text looking better; prefers trail_alpha around200, and previously preferred a.4-second cycle. The new.3-second cycle is the requested comparison.
- Ghosts reflect observed HPP changes, which can combine several hits. Exactly75-point losses do not trigger them. No below2.5% effect or Bind-rule change is included.

---

## Historical testing record (preserved)

# TESTING.md

This document belongs in the repository root and in development/testing packages. Private development and testing record.

## Current testing batch — Batch 3 controls and feedback
- **Version:** `1.1.1-a.20261008.3`. Full runtime overlay; merge `enemybar2/` into the installed addon and reload. No `data` or saved settings included. Root development documents are included.
- **Status:** Lua5.4 parse and mocked regression checks pass; this batch awaits live FFXI testing. Lua5.1/Windower live execution has not been performed here.
- **Commit:** `Refine setup dragging, stack controls and health feedback` follows brighter-text commit `35b40ca`; see git history for SHA.
- **Layout reference:** Supplied `settings(6).xml` has Franklet main400 at470,688; sub300 at470,660; focus250 at470,630; aggro180 at890,563 with six rows and27 spacing, inheriting down. Character fonts12/10/10/10. Resolution not supplied in this file. Preserve installed configuration. Bounds can still reposition groups that exceed the current UI area.

### Live checks for this batch
1. `//eb setup on`: all bars visible; each group moves separately. `//eb setup all on`: entire arrangement moves together. `//eb setup st on`: all visible, only subtarget draggable. Exit with `//eb setup off`.
2. `//eb stack` toggles aggro up/down. `//eb stack up` and `//eb stack down` set it explicitly; legacy stack_dir remains. Bounds may move the stack to keep its full extent on screen.
3. Observe small hits: one-pixel nudge, percentage counts down, no red text flash. At>=25 percentage-point loss text flashes red; over50 retains larger shake. Underbar remains stationary.
4. Below50% red underbar grows progressively more opaque. Between10% and25% fill smoothly fades toward white/transparency; below10% fill blinks pink opaque/transparent with sharp edges, .7 seconds per state by default. Healing interrupts these effects until its transition finishes. ZeroHP hides the fill.
5. Try `//eb trail_alpha 166 all` for65% baseline opacity; `//eb trail_alpha 128 all` restores50%. Observe the difference both above and below50% health. `//eb low_hp_pulse off all` disables the low-health opacity/pulse/blink effects.
6. Reload on Franklet and confirm saved widths/positions/fonts remain. Try the bright healing-text green and damage interruption. Existing locks and bounds controls should still work.

## Previous testing patch — brighter healing text
- **Batch:** 2026-10-08 / Batch 2 color comparison.
- **Contents:** Only `enemybar2/bars.lua`, plus root development documents. Requires Batch 2 already installed; merge the runtime folder and reload enemybar2. Addon version remains `.20261008.2` because this patch does not replace the entry point.
- **Change:** Healing name/percentage flash uses RGB 53/242/100 (`#35F264`), sampled from the upper green reference. The linear .25-second fade, .22-second count-up, and existing healing underbar color remain unchanged.
- **Test:** Observe healing, then damage interrupting healing. Compare green legibility against the prior pale green. This color comparison awaits live feedback.
- **Live results, October 8:** User confirms Batch 1 working and Batch 2 animation looking good; this does not certify every individual edge-case check below.
- **Queued adjustments:** Small shake on all damage; red name flash only for losses >=25 percentage points; white/transparency pulse below25%; strengthen red underbar opacity from50% downward; setup visibility/dragging refinement. These are not included in this color-only comparison.

## Previous testing batch
- **Batch:** 2026-10-08 / Batch 2 — healing, text feedback, hit shakes and low-HP pulses.
- **Package type:** Separate testing overlay, `enemybar2-2026-10-08-batch-2.zip`. Contains Batch 1 controls plus additional animation; merge `enemybar2/` into Windower/addons. Development documents remain at package root; no saved settings are shipped.
- **Version:** `1.1.1-a.20261008.2`.
- **Status:** Offline regression and deterministic animation checks pass. ~~No live result is claimed for either new batch.~~ Correction: user subsequently confirmed Batch 1 working and praised Batch 2 animations in-game. Batch 1 package remains unchanged for separate testing.
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


## Repository documentation adoption record (preserved)

# TESTING.md

Read this first when preparing or evaluating a development/testing batch. This cumulative, project-specific record belongs at the repository and testing-package roots alongside `WORKFLOW.md`.

## Current testing batch — documentation adoption (2026-10-13)

- **Project:** EnemyBar2 (`rerorriM-Mirrorer/enemybar2`).
- **Batch:** Documentation-only adoption; no addon testing package or executable changes.
- **Starting default-branch commit:** `23f18c83bb776644e764be77f81a5955f6ebc56a` (`master`).
- **Documents:** Added root `WORKFLOW.md` and `TESTING.md`.
- **Reference:** [NPCMirror consolidated workflow](https://github.com/rerorriM-Mirrorer/ffxi-NPCmirror/blob/main/WORKFLOW.md).
- **Verification:** Check root filenames and links; compare migration against its starting commit and confirm only Markdown documentation changed.
- **In-game testing:** Not performed for this documentation-only change; existing addon behavior has not been revalidated.

- **Recorded migration commit:** [`7300e6b`](https://github.com/rerorriM-Mirrorer/enemybar2/commit/7300e6bae4cb7e0fd7d9b0b77deb9dcfeee2aace).
- **Verified result:** Git comparison against the recorded starting commit lists Markdown changes only; `WORKFLOW.md` and `TESTING.md` exist at the repository root. No Lua source paths changed.

## Tests for the next functional batch

List the requested change, actions to perform, expected outcomes, previously working behavior to retest, and results actually observed. For UI positioning tests, record the character, resolution, visibility state and actual observed behavior when relevant.

## Previous tests and checks

No historical test results were reconstructed or verified during this documentation migration. Preserve previous testing materials and bring forward only accurately attributed results when reviewed.

## Cumulative changelog

- **2026-10-13 — Navigation refinement:** Corrected the heading levels for the Testing Packages and Shared Development Conventions sections in `WORKFLOW.md` ([`660530d`](https://github.com/rerorriM-Mirrorer/enemybar2/commit/660530d853e8372e066a4829b828901107fa30f2)). Documentation only; no addon code changed.

- **2026-10-13:** Adopted the shared two-document development convention without changing executable addon behavior.

## Delivered packages and documents

| Date | Batch | Item | Type | Commit/reference | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-10-13 | Documentation adoption | WORKFLOW.md; TESTING.md | Repository documents | [`7300e6b`](https://github.com/rerorriM-Mirrorer/enemybar2/commit/7300e6bae4cb7e0fd7d9b0b77deb9dcfeee2aace) | No testing package or Lua changes |

## User-provided materials, observations, and requests

- **2026-10-13 — Shared conventions:** Combine Agathos, Design, and Workflow into one `WORKFLOW.md` with linked table of contents; retain `TESTING.md` as the project-specific historical record; both documents belong in each active repository and testing-package root.
- Add earlier requests, tests, screenshots, files, and observations only when their provenance is verified; record date, batch, and reference.

## Corrections and retention

Correct errors with ~~strikethrough~~, an explanation, and the replacement. Remove historical testing information only by mutual agreement.


## Batch 9 delivery

| Date | Package | Version | Animation commit | Verification |
| --- | --- | --- | --- | --- |
| 2026-10-13 | enemybar2-2026-10-13-batch-9-impact-glow.zip | 1.1.1-a.20261013.9 | 5fc8457 | Lua 5.1 parse, deterministic motion/renderer/commands, offline asset composition; live comparison pending. |
| 2026-10-17 | enemybar2-2026-10-17-batch-10-underbar-glow-complete.zip | 1.1.1-a.20261017.10 | 6356ff4 | Lua 5.1 parsing and three offline regression suites pass; live comparison pending. Push blocked by automatic approval review; source commits remain local. |
