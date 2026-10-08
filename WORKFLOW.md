# WORKFLOW.md

## Principles

**Legibility.**
1. Begin with the ideal solution as imagined or visualized.
2. Identify the established problem.
3. Read upstream code, current fork, last known-good version, and local changes before editing to establish baseline.
4. Review Windower definitions, related addons, available repositories, presented references and `WORKFLOW.md` before theorizing. When uncertain, make direct observations and diagnostics.
5. Present plan for patching and development.
6. Patch the smallest responsible surface, preserving working behavior unless changing it is intentional.
7. Test in layers:
   - **Static:** does the code parse and reveal obvious mistakes?
   - **Smoke:** does it load and perform its basic function?
   - **Regression:** does previously working behavior still work?
   - **Live:** does it behave correctly under the actual conditions that motivated the change?
8. Commit coherent units of work; every conceptual change produces one comprehensible commit or small sequence of commits describing intention.
9. Preserve and tag known-good states and snapshots: `main`/`master` represents the last version trusted after live testing; Untested work remains on a working branch.
10. **Document continuously.** Keep README, defaults, help/status output, comments, diagnostics, and repeatable test instructions (`TESTING.md`) aligned with desired behavior. While developing in Codex, give frequent reports on work and thought process. Record user-visible changes in cumulative changelog included at the end of each README. Report findings and patches as work proceeds. Git history remains the complete mechanical record.


### 11. Review Before Delivery

Before presenting a completed batch:
- Review changes against original request.
- Check for unintended changes or regressions.
- Perform appropriate static checks and available tests.
- Confirm which changes have actually been tested.
- Review documentation and comments for accuracy.
- Identify any remaining uncertainties.
- Report commit and push status.
- Suggest worthwhile follow-up improvements.

---


## Static checking

Before live testing, run Lua 5.1-aware static checks against Windower's API definitions where available. Catch syntax errors, unintended globals, API mistakes, and other obvious problems before FFXI testing. Static checking complements rather than replaces smoke, regression, and live testing.

---


## Packet investigation

Packet injection is welcome as a solution but requires stronger justification than packet observation. Determine when packet observation is warranted and ask for controlled captures when live observation is required.

For packet-dependent work, maintain `docs/PACKETS.md` recording:
- scenario/action
- incoming/outgoing direction
- packet ID
- relevant observed fields
- repeated observations and variations
- what is known versus inferred
- confidence and unresolved questions

---


###  Testing Packages & Development Records

- **README.md**

   - Keep `README.md` focused on configuration and use, ending with cumulative changelog.

- **TESTING.md**
   
   - Maintain `TESTING.md` at the repository root as the first guide for installation, development and testing (alongside redundant `WORKFLOW.md`, `DESIGN.md`, and `AGATHOS.md` copies)
      - Each testing delivery should identify its batch, associated commit(s), its contents, and any installation precautions.
      - Update `TESTING.md` before delivering a new testing batch. Include current tests first, followed by previous checks and results, a delivery register, and a record of user-provided materials, observations, and requests.
      - Preserve historical information without presenting unverified reconstruction as fact. 
      - `TESTING.md` is a cumulative record. Correct inaccurate information using strikethrough, an explanatory note, and the corrected information. Remove historical information only by mutual agreement.

---


## Authorship

**A is the collaborative authoring identity of this continuing practice.**


---


### Shared Development Conventions

Use the development documents maintained in the NPCMirror repository as the reference for shared practices across projects.

Maintain `AGATHOS.md`, `DESIGN.md`, `WORKFLOW.md`, and `TESTING.md` at the root of each active development repository and testing package.

Review these conventions when beginning development work or preparing a new testing batch. Preserve project-specific principles, documentation, and history when adopting shared conventions. Propagate improvements deliberately, reviewing differences rather than overwriting existing material. 

Reflect useful improvements back into the shared reference when appropriate.


---


Review `DESIGN.md`
