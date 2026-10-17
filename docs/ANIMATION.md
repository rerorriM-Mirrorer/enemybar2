# Health feedback references and decisions

Reviewed 2026-10-08 for Batch 2. This is a reading of primary-source talk summaries, research abstracts and a developer's health UI walkthrough; no claim is made to have watched the embedded videos or measured their frame timing.

- [Juice It or Lose It — Martin Jonasson and Petri Purho, GDC](https://gdcvault.com/play/1016789/Juice-It-or-Lose): a demonstration of layering game feedback. Our adaptation is deliberately staged: trail first, then recovery and text, then small hit/low-HP cues.
- [Don't Juice It or Lose It — Folmer Kelly, GDC](https://www.gdcvault.com/play/1021398/Don-t-Juice-It-or): the summary argues that polish needs context and can reduce immersion when it conflicts with the depicted material. Our inference for FFXI is to keep geometry fixed between events and make shakes brief and switchable.
- [What Features Influence Impact Feel? — Lin et al., 2022](https://arxiv.org/abs/2208.06155): studies action-game impact feedback and reports potential importance of hit stop, sound coherence and camera control. This is not evidence that a slower MMORPG needs those effects. We change only addon primitives, without camera shake, game pauses or extra sounds.
- [UE5 Health Bar UI — Rambod Dev](https://rambod.net/tutorial/ue5-health-bar-ui): a developer-authored health UI walkthrough. It provides a comparison for separating HP state from its on-screen presentation, rather than a timing prescription for this addon.

## Chosen test behavior

The user's specification determines the effects. Batch 2 keeps a .35-second healing fill, a .22-second numeric transition, a .25-second text flash and a 1.4-second continuous low-HP cycle. These are starting values for live comparison, not findings from the references.

Large-hit shakes use the observed HPP difference in percentage points of maximum health, not a percentage of remaining health. The strict thresholds are >25 and >50 points; each shake returns to its logical base position. A delayed/combined HPP update can represent multiple attacks, so this is feedback for a health change rather than independently verified individual damage events.

Damage takes priority over recovery. Recovery takes priority over low-HP color pulsing until its fill transition finishes. Text flash blends toward the current semantic name color, so NPC/enemy status coloring is restored. The trail never shares the shake offset. Zero HP stops pulsing; changed target IDs reset feedback. Below 2.5% has no special extra effect yet. FFXI's integer HPP limits threshold precision and numeric animation to whole percentages.

The color/opacity effects apply to the chosen frame's configured resource tint: pink main/focus, blue subtarget or green aggro. Healing starts white and returns to that tint. Supporting action/target labels retain their usual colors. Caps/trough and foreground shake; name text remains stationary for readability.

## Tunable switches

`healing_effect`, `text_effect`, `hit_shake`, `low_hp_pulse` each support on/off with an optional frame. `heal_duration`, `text_duration` and `pulse_period` accept seconds. A pulse period must be greater than zero. Use `all` explicitly to change all frames. The separate damage-trail settings from Batch 1 remain available.

## Batch 3 refinement
All damage nudges; red text flash requires>=25 percentage-point loss. Below25% white/transparency pulse; below10% sharp pink on/off blink. Red underbar opacity strengthens linearly from its base at50% HP toward overall bar opacity near zero. Basic setup is individual dragging; all explicitly moves the arrangement.


## Batch 4 refinement — 2026-10-10

Current opacity follows100–0% HP linearly. Color shifts from original red to224/86/130 across50–10% HP without oscillation; below10% it smoothly oscillates from that red to255/130/160. Foreground10–25% retains the prior white fade with a25% alpha floor; below10% sharply alternates full and25% alpha. Default full cycle is.3 seconds, preserving saved user periods.

Ghost hit overlays trigger on observed losses strictly greater than75 points. Separate primitives snapshot the lost segment's original screen geometry and tint; they flash pale, return to red, ease upward4px and fade quadratically over.35 seconds. Multiple short-lived chunks can coexist. Gauge hide/destruction/identity reset do not own their lifetime; scene transitions and unload clear them. The live foreground and trail continue normally. Death cancels the trail delay and uses.15-second collapse, while detached ghosts finish. These choices implement the user's proposal; no additional video research is claimed for Batch4.


## Batch 5 — current design

Two-second detached white ghost:12px eased lift in.2s, hover through1s, then10px up/right drift with linear white-to-red transition and alpha fade over the final second. A75-point-or-larger observed drop triggers it; the independent red trail never shakes. Main shell/fill super-hit shake uses6,-8,0px over.3s when ghost_hit and hit_shake are enabled.

Above10% foreground stays steady. Red underbar pulses normal/brighter red at or below50%; at or below10% it pulses brighter red/white and foreground sharply alternates100%/25% opacity. HP-based opacity still runs across100–0%.

Observed death numeric transition is capped at.15s. Each live bar retains its own death timestamp separately from its resettable renderer identity, preserving a.65s total display after auto-detarget; reassignment to a new target overrides it. Explicit hide/scene transitions cancel display holds. Repeated corpse samples do not restart the hold. Independent ghosts keep their own snapshot/lifetime. No speculative death is inferred from disappearance alone.


## Batch 6 — current tuning

Ghost trajectories/timing/alpha are snapshotted per detached chunk: default6px up/1px right during.2s eased lift, .8s hover, then9px up/1px right during1s linear drift/white-to-red fade. Smooth cosine alpha cycles fully transparent to configuredmaximum every.1s, multiplied by the final fade;0period disables it. Frame alpha also limits maximumopacity. Commands share centralized defaults/ranges in animationSettings.lua.

Split live clocks defaultforeground.25s / underbar.1s; old shared savedtiming migrates to missing splitclocks. pulse_period sets both. Super settling options small(default.42s total), both(.60s), off(.30s). Aggro0HP never renders a deathhold: a visible prior identity samples its killinghit before being hidden and survivors compact. Only main target retains the.65s deathdisplay. Preview lifecycle is separated in animationPreview.lua and cleaned alongside scene transitions.


## Batch 7

All shake phases now use held integer offsets: small1/-1/rest, medium3/-4/rest, super6/-8/rest, multiplied by the random starting direction. Existing phase durations/settling ordering remain. Boundary comparisons tolerate floating-point timestamp subtraction. No interpolation is applied to shaking. Current user-tuned defaults resolve supplied global+Franklet settings; defaults do not overwrite saved experiments. Ghost/fill/text interpolation remains independent.


## Batch 8

Super-hit core now holds6px for.05s, opposite8px for.05s, and rests.03s before settling. Total core.13s; with small settling.25s; with medium then small.43s. Ordinary hit/settling amplitudes and durations are preserved.


## Batch 9 — contact, decreasing impulse and detached glow

Reviewed current XIVParty `uiBar.lua`, `uiStatusBar.lua`, FFXI/XIV layouts and FFXI glow textures through the source repository: https://github.com/Tylas11/XivParty. With glow enabled, the fill snaps while an animated value catches up, and a stretched middle plus two edge images outline the differing interval. Our experiment preserves the ghost's lost-interval width and contracts the glow vertically instead. New gradients are procedural neutral textures, not copies of XIVParty assets.

The provided FFXVI screenshot shows a bright white foot and a tall translucent red flare at the fill edge. Timing is our proposed interpretation, not a measured recreation from a still image. Primary references read: Mariel Cartwright's GDC talk summary on strong key frames and timing (https://www.gdcvault.com/play/1020017/Animation-Bootcamp-Fluid-and-Powerful), and GDQuest's developer explanation of white impact flash, reactive motion and brief contact holds (https://www.gdquest.com/library/juicy_attack/). No claim is made to have watched the embedded talks or measured their frame timings.

New impact shake defaults to first displacement 8px for super hits, first rebound half strength, later rebounds half their predecessor, first hold .05s and later holds 1/30s. Held positions are rounded to pixels; no shake interpolation. `super_settle` selects 2/3/4 phases (off/small/both); ordinary/medium use four phases, with rounded tiny corrections naturally becoming zero. Previous sequences remain under `shake_style classic`. Optional horizontal movement is a ratio of the vertical displacement.

Ghosts add a .05s solid white stationary contact before the saved lift/hover/fade. Flicker starts after contact. A steady, separate red glow and two paler edge flares follow the detached chunk, shrinking vertically and fading over .4s after contact; the chunk's lifetime bounds their duration. All geometry, colors and tuning are snapshotted, including explicit false. Every overlay primitive is destroyed on expiry/scene cleanup. Red trail timing, pulse behavior, numeric death countdown, target identity, setup guard and tracking are inherited from the tested package.

A distinct full-health finishing hit, the Bind/debuff correctness review and alternate Trust bar skin remain deferred by agreement.

Offline texture composition exposed a cyan cast when the native fill is tinted white. Ghost-only neutral silhouettes retain its alpha geometry, allowing a white contact flash and a direct white-to-red tint transition; live gauge assets remain unchanged.

## Batch 10 — red underbar glow and critical foreground color

The underbar uses the existing normal-to-brighter-red cycle at all positive HP <=50%, with no critical white endpoint. Its linear HP-based opacity calculation is unchanged. At <=10%, the foreground sharply alternates between its resource tint and true white at constant configured opacity using its independent clock. Neutral silhouette copies provide the white phase without changing the normal fill's original cyan-tinted texture; healing retains its prior priority.

Three optional primitives decorate each trail: a stretched middle, and flares centred on its left and animated right edges. The middle extends3px above/below and has alpha80; flares extend8px upward, width3px, alpha140. Their alpha is multiplied by the current trail opacity and their tint follows its current pulse color. They follow held/shrinking trail geometry, width changes and dragging; they never inherit shake or ghost motion. Very narrow trails cap flare width to half the visible trail span. Zero width, hide, destruction and green healing suppress the decoration. `underbar_glow off` avoids creating the three primitives altogether.

`preview hp <1..100> [bar]` presents chosen HP for8s without a detached ghost, alongside the existing ghost preview. Actual ghost threshold remains observed loss>=75 percentage points. The user's tentative kill-only restriction was explicitly withdrawn. Saved ghost tuning is retained; the supplied latest Franklet settings are recorded in TESTING rather than installed as user data or new defaults.
