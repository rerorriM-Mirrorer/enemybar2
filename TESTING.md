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
