# DESIGN.md

## Addon behavior and UI extend and enhance FFXI rather than fighting it
**The best state for many of these tools is almost invisible.**
Prefer FFXI-like typography, spacing, borders, and restrained visual hierarchy.

**The addon should feel as though the game gained a missing capability.**

---

## Configuration is interface

Good defaults matter more than enormous configuration files. Expose a setting because a user may reasonably want to change it. Where sensible, commands support:

`//addon command on`  
`//addon command off`  
`//addon command`

A bare command may toggle when that behavior is useful and obvious. Explicit state-setting commands should be idempotent:

`edit on` always leaves editing on and reports that state.

Help output should make `<required>` and `[optional]` parameters obvious.

Dragging and edit modes should be discoverable but disappear when not needed.

---

## Multiboxing informs engineering priorities

Assume partial success.

“Three succeeded and one did not” is a normal state that should be diagnosable, not an exceptional condition that collapses the whole operation. Where practical, commands operate independently per client and report successes and failures per character. Resolve roles dynamically—leader, `<p1>`, anchor, current party lead, configured role—inside program logic. Individual character names assigned to those roles belong in configuration. Design timing, behavior, and resource use with multiple simultaneous clients in mind.

---

## Windower conventions

- Defaults belong in the addon; `config` populates user settings.
- User-modified persistent state belongs under `data`.
- New settings merge gracefully into existing configurations.
- Use `local` variables and functions by default. Create globals only when something outside their local scope must access them.
- As commands grow, keep command parsing small and hand individual commands to separate local handler functions rather than one large `if/elseif` chain.
- Every addon provides useful `help` and `status` commands. A bare addon command may report status where appropriate.
- Prefer existing Windower libraries and definitions over recreating equivalent behavior.


---

## State and sequencing

When an addon develops several interacting modes or asynchronous steps, prefer an explicit state machine over accumulating loosely related boolean flags.

Prefer:

**observe completion of A → perform B**

over:

**wait an arbitrary time → assume A completed → perform B**

Delays remain appropriate as buffers when no reliable completion signal exists.

---

## Diagnostics

Addons should be able to report their basic running state.

Where relevant, diagnostics should answer:
- What version am I running?
- What mode am I in?
- What major toggles are active?
- Where is my UI positioned?
- What target, character, or state am I operating against?
- Is debugging enabled?

Diagnostic levels:

**Normal** — quiet except for useful user feedback.
**Debug** — explains important decisions and state changes.
**Trace** — exposes detailed state transitions, packet IDs, target data, or other investigation information.

Failures should be specific enough to identify which step or character failed.

---

## Comments

Comments explain **function, intent, and causality**, especially for someone curious about the code but not yet fluent in Lua.

Particularly comment:
- modifications from upstream
- deliberately preserved or dormant behavior
- code whose removal would have unexpected consequences

Educational comments may be reduced later when preparing a final upstream release.

---

Review `AGATHOS.md`
