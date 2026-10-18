# Questions for the next visual pass

These are proposals for later testing, not additional effects silently enabled in Batch12. The requested preset, flash controls, white/trail ghost fade, proportional underbar size and synchronized ghost height are delivered separately.

## What should a glance communicate?

Current HP must remain distinguishable from delayed damage, and the enemy's name should remain readable. The glow can look dramatic in a preview but still needs comparison while following, targeting and reading chat. Test against both dark night scenes and bright sand/sky; a pale flare that looks beautiful over darkness can disappear over a bright scene.

## Which event earns the largest accent?

The user's supplied main bar is intentionally broad and luminous; aggro/sub/focus retain smaller effects. Preserve that hierarchy. Before adding another layer, decide whether it conveys new information: ordinary hit, unusually large observed loss, low remaining HP, healing, or observed death. Several effects can reinforce one event if they have one clear onset and decay rather than unrelated rhythms.

The exposed red interval represents unresolved delayed damage and can grow across repeated smaller hits. Since Batch13, ghosts trigger on an observed >=75-percentage-point change or a positive-HP->0% transition. Samples may combine packet updates; they are not proof of a single attack. Any future attack-specific distinctions would require action correlation rather than pretending HP samples establish them.

## Does the ending feel intentional?

Potential next experiment: let width disappear faster than height, leaving narrow wisps, then end cleanly without minimum-size remnants. Batch12 already exposes separate width/height curves for that comparison. A distinct death release could be a short final inward contraction or a tiny edge spark, instead of a second large flash. Keep it an option and compare it against the current brief0% main-bar hold before choosing.

### Death sparkle asset brief — implemented in Batch14

As the red trail finishes collapsing to zero, a tiny four-point glint appears at its closing endpoint (the left foot of the gauge). A2–3px white core sends slightly uneven rays roughly6–8px outward, with a longer horizontal axis and a faint rose-gold halo. Total lifetime about.15–.25s: quick bloom, soft release, no repeating pulse or shower. The finishing-hit ghost carries the lost HP away independently while this glint stays at the closure point. It must be able to finish after a compact bar hides.

The user suggested matching BarFiller2's sparkle assets so both addons share a visual language. Batch14 inspected the complete Grid Test3 package and reuses the two exact gain-sparkle arm sprites from `assets/slider/`, as used by `trust_gauge.lua`. The initial implementation preserves their thin white/gold core and soft warm halo rather than creating another texture. Default lengths16px horizontal/12px vertical, alpha230 and lifetime.2s; a fast bloom is followed by a softer release. It starts at the left endpoint after the existing.15s death-trail collapse, survives compact-bar hiding, and is independent of the finishing ghost. Switch/alpha/size/duration are adjustable per bar. No specific FFXI DAT asset has been claimed for these sprites. The sparkle was not implemented in Batch13; this is its first test delivery.

### Recovery experiment — delivered in Batch13

Main-only recovery halo and white/pale-green edge flares now decorate the closing green recovery interval. They use the existing healing clock, fade and shrink with the interval, and stop on interruption. Per-hit ghost asymmetry, role-specific continuous flashing and the reported rectangular ghost-flare artifact remain separate follow-ups.

## Does scale mean the same thing on both clients?

Damage response now uses exposed fraction of bar width, while flare heights remain UI pixels. That intentionally separates how much health was lost from how large the interface is. Compare Cioara's actual UI resolution and on-screen gauge width with Franklet's before changing the animation curve. A future overall effect-scale control could preserve the same physical impression across clients without rewriting every height/width.

## Does the effect still feel good after an hour?

Future optional refinements: a main-target/aggro intensity multiplier; a quieter long-session preset; a brief asymmetric flare overshoot; very small, deterministic variation between the two ghost edges. Test one at a time. Small variation can make releases less mechanical, but random jitter on every frame would compete with the deliberate flicker rhythm.

## Does it remain inexpensive and recoverable?

Keep per-frame work allocation-free where practical; avoid creating/destroying images every pulse. Cache per-bar options and snapshot only when a ghost is born. Check target changes, setup exit, death, cutscene, zoning and unload for orphaned images. With fast kills across many aggro entries, consider a configurable ghost-count budget or recycled image pool only if observed load warrants it. Use elapsed time for animation and compare30/60FPS; describe observed differences rather than assuming offline timestamps prove live cadence.

Batch12's lifecycle smoke test covers duplicate restart/unload requests and queued drawing after cleanup. Its tests do not measure the cost of multi-client Windower rendering.

## Primary references read

- [Mariel Cartwright, Animation Bootcamp: Fluid and Powerful Animation within Frame Restrictions, GDC2014](https://www.gdcvault.com/play/1020017/Animation-Bootcamp-Fluid-and-Powerful): the session summary emphasizes strong key frames and timing within very few frames. The embedded talk was not measured or claimed watched.
- [GDQuest, Juicing up your game attacks](https://www.gdquest.com/library/juicy_attack/): developer examples show reaction timing, white contact flashes, easing, layered effects and particle scale over a lifetime. Our adaptation is for addon UI primitives, not a prescription to change FFXI's world/camera timing.

The questions and suggested experiments above are our design inferences for this addon. They are not claims that either source reviewed EnemyBar2.
