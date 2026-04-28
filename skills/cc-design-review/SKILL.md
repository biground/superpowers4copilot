---
name: cc-design-review
description: "Reviews a game design document for completeness, internal consistency, implementability, and adherence to project design standards. Run this before handing a design document to programmers."
---

## Phase 0: Parse Arguments

Extract `--depth [full|lean|solo]` if present. Default is `full`.

- **`full`**: Complete review — all phases + specialist agent delegation (Phase 3b)
- **`lean`**: All phases, no specialist agents — faster, single-session analysis
- **`solo`**: Phases 1-4 only, no delegation, no Phase 5 — use when called from within another skill

---

## Phase 1: Load Documents

Use `read_file` on the target design document in full. Read project context (CLAUDE.md or equivalent). Read related design documents from `design/gdd/`.

**Dependency graph validation:** For every system in the Dependencies section, use `file_search` to check whether its GDD file exists. Flag missing files.

**Lore/narrative alignment:** If `design/gdd/game-concept.md` or files in `design/narrative/` exist, read them. Note contradictions with design pillars.

**Prior review check:** Check whether `design/gdd/reviews/[doc-name]-review-log.md` exists. If so, read the most recent entry and track whether prior blockers were addressed.

---

## Phase 2: Completeness Check

Evaluate against the Design Document Standard checklist:

- [ ] Has Overview section (one-paragraph summary)
- [ ] Has Player Fantasy section (intended feeling)
- [ ] Has Detailed Rules section (unambiguous mechanics)
- [ ] Has Formulas section (all math defined with variables)
- [ ] Has Edge Cases section (unusual situations handled)
- [ ] Has Dependencies section (other systems listed)
- [ ] Has Tuning Knobs section (configurable values identified)
- [ ] Has Acceptance Criteria section (testable success conditions)

---

## Phase 3: Consistency and Implementability

**Internal consistency:**
- Do formulas produce values matching described behavior?
- Do edge cases contradict main rules?
- Are dependencies bidirectional?

**Implementability:**
- Are rules precise enough for a programmer?
- Any "hand-wave" sections with missing details?
- Performance implications considered?

**Cross-system consistency:**
- Conflicts with existing mechanics?
- Unintended interactions with other systems?
- Consistent with game's tone and pillars?

---

## Phase 3b: Adversarial Specialist Review (full mode only)

**Skip this phase in `lean` or `solo` mode.**

### Step 1 — Identify all domains the GDD touches

| If the GDD contains... | Spawn these agents |
|------------------------|-------------------|
| Costs, prices, drops, rewards | `cc-economy-designer` |
| Combat stats, damage, health | `cc-game-designer`, `cc-systems-designer` |
| AI behaviour, pathfinding | `cc-ai-programmer` |
| Level layout, spawning | `cc-level-designer` |
| UI, HUD, menus | `cc-ux-designer`, `cc-ui-programmer` |
| Dialogue, quests, story | `cc-narrative-director` |
| Multiplayer, sync | `cc-network-programmer` |
| Audio cues, music triggers | `cc-audio-director` |
| Performance concerns | `cc-performance-analyst` |
| Engine-specific patterns | Primary engine specialist |
| Acceptance criteria | `cc-qa-tester` |
| Any gameplay system | `cc-game-designer` (always) |

**Always spawn `cc-game-designer` as baseline minimum.**

### Step 2 — Spawn all relevant specialists in parallel

Issue all `runSubagent` calls simultaneously. Do NOT spawn one at a time.

**Prompt each specialist adversarially:**
> "Your job is NOT to validate this design — your job is to find problems.
> Challenge the design choices from your domain expertise."

### Step 3 — Senior lead review

After all specialists respond, spawn `cc-creative-director` via `runSubagent` as the **senior reviewer** to synthesize findings and produce the final verdict.

### Step 4 — Surface disagreements

If specialists disagree, present the disagreement explicitly. Mark every finding with its source agent.

---

## Phase 4: Output Review

```
## Design Review: [Document Title]
Specialists consulted: [list]
Re-review: [Yes / No]

### Completeness: [X/8 sections present]

### Dependency Graph
- ✓ [system].md — exists
- ✗ [system].md — NOT FOUND

### Required Before Implementation
[Numbered list — blocking issues only. Source-tagged.]

### Recommended Revisions
[Numbered list — important but not blocking.]

### Specialist Disagreements
[Both sides presented — do not silently resolve.]

### Senior Verdict [cc-creative-director]
[Synthesis and overall assessment.]

### Scope Signal
- **S** — single system, no formulas, <3 dependencies
- **M** — moderate complexity, 1-2 formulas, 3-6 dependencies
- **L** — multi-system integration, 3+ formulas, may require new ADR
- **XL** — cross-cutting concern, 5+ dependencies, multiple new ADRs likely

### Verdict: [APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED]
```

---

## Phase 5: Next Steps

Use `vscode_askQuestions` for ALL closing interactions.

**If NEEDS REVISION or MAJOR REVISION NEEDED:**
- `[A] Revise the GDD now — address blocking items together`
- `[B] Stop here — revise in a separate session`
- `[C] Accept as-is and move on`

**If user selects [A] — Revise now:**
Work through all blocking items. Group design-decision questions into a single `vscode_askQuestions`.
After revisions, show summary table and closing widget.

**Systems index update widget:**
- "May I update `design/gdd/systems-index.md` to mark [system] as [In Review / Approved]?"
- Options: `[A] Yes` / `[B] No`

**Review log widget:**
- "May I append this review to `design/gdd/reviews/[doc-name]-review-log.md`?"
- Options: `[A] Yes` / `[B] No`

If yes, append:
```
## Review — [YYYY-MM-DD] — Verdict: [verdict]
Scope signal: [S/M/L/XL]
Specialists: [list]
Blocking items: [count] | Recommended: [count]
Summary: [2-3 sentences]
Prior verdict resolved: [Yes / No / First review]
```

**Final closing widget** — dynamically built options:
- Run `/cc-design-review [other-gdd]` if another GDD needs review
- Run `/cc-consistency-check` to verify values
- Run `/cc-review-all-gdds` if ≥2 GDDs exist
- Run `/cc-design-system [next-system]` — next in design order
- Stop here

Mark the most pipeline-advancing option as `(recommended)`.
