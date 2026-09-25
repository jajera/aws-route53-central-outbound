---
inclusion: fileMatch
fileMatchPattern: "docs/**"
---

# Documentation page pattern

## Shape

1. One H1 (page title).
2. Short lede (story or outcome).
3. Visuals first where the page compares designs (ASCII / Mermaid / tables).
4. Short sections — avoid wall-of-text.
5. Link onward (Design / Cost / Demo) instead of repeating other pages.

## Overview (`index.md`)

- Patina hero + at-a-glance table.
- Path cards match nav order: Patterns → Design → Cost → Demo.
- “What this does not do” only for real exclusions (Profiles, Firewall, multi-region demo) —
  not for things the comparison assumes (on-prem connectivity).

## Patterns (`patterns.md`)

Continuous story:

1. One VPC ≈ standalone; central adds unused RAM.
2. Two VPCs → cost benefit starts.
3. Scale + ownership tradeoffs.
4. **Cost is not the only tradeoff** — blast radius, escape hatch, chargeback, path to DNS
   (diagrams `blast-radius.svg`, `escape-hatch.svg`, `chargeback-and-path.svg`).
5. Close with **Takeaway** — situation → choose table (not a separate Summary page).
   Point to [References](../docs/references.md) for sources; do not bury a References
   section on Patterns itself.

Do not dump an “alternatives not built” table that duplicates Overview.

## References (`references.md`)

Standalone nav page **after Demo**. Tables of AWS docs/posts this site builds on
(Resolver, HA/blast radius, RAM, pricing). Keep Patterns/Design free of long source lists.

- Assumptions table, formula, side-by-side, scaling table.
- Separate **demo overhead** from the pattern delta.
- Price source + retrieval date required.

## Demo (`docs/demo/`)

Multi-page walkthrough — keep each file one job:

| Page | Job |
| --- | --- |
| `index.md` | What you build + step index |
| `prerequisites.md` | Tools, RAM, cost warning |
| `profiles.md` | STS / SSO |
| `hub.md` | Network apply (central) |
| `spokes.md` | Dev + sandbox associate shared rule |
| `verify.md` | SSM dig + expected answers |
| `teardown.md` | Destroy order |
| `troubleshooting.md` | Symptom table |

Author commands; operator runs apply/destroy. Expected `dig` answers stay next
to the verify step.

## Code blocks

- Shell commands the reader runs in `bash` fences.
- Verified or expected output in a following `text` fence — do not mix stdout into the command.
- Use account `123456789012` in sample ARNs.
