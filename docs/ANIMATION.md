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
