---
name: cc-review-all-gdds
description: "Holistic cross-GDD consistency and game design review. Reads all system GDDs simultaneously and checks for contradictions, stale references, ownership conflicts, formula incompatibilities, and game design theory violations. Run after all MVP GDDs are written, before architecture begins."
---

# Review All GDDs

This skill reads every system GDD simultaneously and performs two complementary
reviews that cannot be done per-GDD in isolation:

1. **Cross-GDD Consistency** — contradictions, stale references, ownership conflicts
2. **Game Design Holism** — dominant strategies, broken economies, cognitive overload, pillar drift

**Distinct from `/cc-design-review`**: that reviews one GDD internally. This reviews *relationships* between all GDDs.

**When to run:**
- After all MVP-tier GDDs are individually approved
- After any GDD is significantly revised mid-production
- Before `/cc-create-architecture` begins

**Argument modes:**
- **No argument / `full`**: Both consistency and design theory passes
- **`consistency`**: Cross-GDD consistency checks only (faster)
- **`design-theory`**: Game design holism checks only
- **`since-last-review`**: Only GDDs modified since the last review report

---

## Phase 1: Load Everything

### Phase 1a — L0: Summary Scan (fast)

Use `grep_search` to extract `## Summary` sections from all GDDs before full reads.

Display a manifest to the user listing all found GDDs with summaries.

For `since-last-review`: use `run_in_terminal` with `git log --name-only` to identify modified GDDs.

### Phase 1b — Registry Pre-Load

Use `read_file` on `design/registry/entities.yaml` if it exists. Use it as a
conflict baseline. If absent, note: "Entity registry empty — run `/cc-consistency-check` after."

### Phase 1c — Full Document Load

Use `read_file` on:
1. `design/gdd/game-concept.md`
2. `design/gdd/game-pillars.md` if it exists
3. `design/gdd/systems-index.md`
4. Every in-scope system GDD

Report: "Loaded [N] system GDDs covering [M] systems."

If fewer than 2 system GDDs exist, stop.

---

### Parallel Execution

Phase 2 (Consistency) and Phase 3 (Design Theory) are independent — spawn both
as parallel `runSubagent` agents simultaneously.

---

## Phase 2: Cross-GDD Consistency

### 2a: Dependency Bidirectionality
Check every dependency is reciprocal. Flag one-directional dependencies.

### 2b: Rule Contradictions
Scan for floor/ceiling conflicts, resource ownership conflicts, state transition disagreements, timing assumptions, stacking rule conflicts.

### 2c: Stale References
Verify every cross-document reference still exists and matches.

### 2d: Data and Tuning Knob Ownership Conflicts
Flag duplicate ownership of the same data or tuning knob.

### 2e: Formula Compatibility
Check output ranges of upstream formulas match expected input ranges downstream.

### 2f: Acceptance Criteria Cross-Check
Find acceptance criteria that cannot both pass simultaneously.

---

## Phase 3: Game Design Holism

### 3a: Progression Loop Competition
Flag multiple systems competing equally as the primary progression driver.

### 3b: Player Attention Budget
Count simultaneously active systems. Flag if >4 concurrent active systems.

### 3c: Dominant Strategy Detection
Flag resource monopolies, risk-free power, no-tradeoff options, obvious optimal paths.

### 3d: Economic Loop Analysis
Map all resources → sources and sinks. Flag: infinite source/no sink, sink/no source, source >> sink, positive feedback loops, no catch-up mechanics.

### 3e: Difficulty Curve Consistency
Compare scaling curves across systems. Flag mismatched exponential vs linear scaling.

### 3f: Pillar Alignment
Flag systems that serve no design pillar. Flag anti-pillar violations.

### 3g: Player Fantasy Coherence
Flag incompatible player fantasies across systems.

---

## Phase 4: Cross-System Scenario Walkthrough

### 4a: Identify Key Multi-System Moments
Find 3–5 moments where multiple systems activate simultaneously.

### 4b: Walk Through Each Scenario
For each scenario: Trigger → Activation order → Data flow → Player experience → Failure modes (race conditions, feedback loops, broken state transitions, contradictory messaging, compounding difficulty spikes, reward conflicts, undefined behavior).

### 4c: Flag Scenario Issues
Categorize: BLOCKER / WARNING / INFO. Cite scenario name, systems, step, failure mode.

---

## Phase 5: Output the Review Report

```
## Cross-GDD Review Report
Date: [date]
GDDs Reviewed: [N]
Systems Covered: [list]

---

### Consistency Issues
#### Blocking
🔴 [Issue title and details]

#### Warnings
⚠️  [Issue title and details]

---

### Game Design Issues
#### Blocking
🔴 [Issue title and details]

#### Warnings
⚠️  [Issue title and details]

---

### Cross-System Scenario Issues
[Scenarios walked with BLOCKER/WARNING/INFO findings]

---

### GDDs Flagged for Revision
| GDD | Reason | Type | Priority |

---

### Verdict: [PASS / CONCERNS / FAIL]
```

---

## Phase 6: Write Report and Flag GDDs

Use `vscode_askQuestions`:
- "May I write this review to `design/gdd/gdd-cross-review-[date].md`?"
- Options: `[A] Yes` / `[B] No`

If GDDs are flagged, second `vscode_askQuestions`:
- "Update systems index to mark flagged GDDs as Needs Revision?"
- Options: `[A] Yes` / `[B] No`

### Session State Update

Silently append to `production/session-state/active.md`.

---

## Phase 7: Handoff

Use `vscode_askQuestions` with dynamically built options:
- Apply quick fix for simple-edit warnings
- Run `/cc-design-review [flagged-gdd]`
- Run `/cc-design-system [next-system]`
- Run `/cc-create-architecture` (if verdict is not FAIL)
- Run `/cc-gate-check` (if verdict is PASS)
- Stop here

Mark most pipeline-advancing option as `(recommended)`.
