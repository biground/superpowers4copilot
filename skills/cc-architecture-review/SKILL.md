---
name: cc-architecture-review
description: "Validates completeness and consistency of the project architecture against all GDDs. Builds a traceability matrix mapping every GDD technical requirement to ADRs, identifies coverage gaps, detects cross-ADR conflicts, verifies engine compatibility consistency across all decisions, and produces a PASS/CONCERNS/FAIL verdict."
---

# Architecture Review

The architecture review validates that the complete body of architectural decisions
covers all game design requirements, is internally consistent, and correctly targets
the project's pinned engine version. It is the quality gate between Technical Setup
and Pre-Production.

**Argument modes:**
- **No argument / `full`**: Full review — all phases
- **`coverage`**: Traceability only — which GDD requirements have no ADR
- **`consistency`**: Cross-ADR conflict detection only
- **`engine`**: Engine compatibility audit only
- **`single-gdd [path]`**: Review architecture coverage for one specific GDD
- **`rtm`**: Requirements Traceability Matrix — extends the standard matrix
  to include story file paths and test file paths; outputs
  `docs/architecture/requirements-traceability.md` with the full
  GDD requirement → ADR → Story → Test chain. Use in Production phase.

---

## Phase 1: Load Everything

### Phase 1a — L0: Summary Scan (fast, low tokens)

Before reading any full document, use `grep_search` to extract `## Summary` sections
from all GDDs and ADRs:

```
grep_search query="## Summary" includePattern="design/gdd/*.md"
grep_search query="## Summary" includePattern="docs/architecture/adr-*.md"
```

For `single-gdd [path]` mode: use the target GDD's summary to identify which
ADRs reference the same system, then full-read only those ADRs. Skip unrelated GDDs.

For `engine` mode: only full-read ADRs — GDDs are not needed for engine checks.

For `coverage` or `full` mode: proceed to full-read everything below.

### Phase 1b — L1/L2: Full Document Load

Read all inputs appropriate to the mode using `read_file`:

### Design Documents
- All in-scope GDDs in `design/gdd/` — read every file completely
- `design/gdd/systems-index.md` — the authoritative list of systems

### Architecture Documents
- All in-scope ADRs in `docs/architecture/` — read every file completely
- `docs/architecture/architecture.md` if it exists

### Engine Reference
- `docs/engine-reference/[engine]/VERSION.md`
- `docs/engine-reference/[engine]/breaking-changes.md`
- `docs/engine-reference/[engine]/deprecated-apis.md`
- All files in `docs/engine-reference/[engine]/modules/`

### Project Standards
- Project technical preferences file

Report a count: "Loaded [N] GDDs, [M] ADRs, engine: [name + version]."

**Also read `docs/consistency-failures.md`** if it exists. Extract entries with
Domain matching the systems under review. Surface recurring patterns as a
"Known conflict-prone areas" note at the top of Phase 4 output.

---

## Phase 2: Extract Technical Requirements from Every GDD

### Pre-load the TR Registry

Before extracting requirements, use `read_file` on `docs/architecture/tr-registry.yaml`
if it exists. Index existing entries by `id` and by normalized `requirement`
text. This prevents ID renumbering across review runs.

For each requirement extracted, the matching rule is:
1. **Exact/near match** to existing registry entry for the same system →
   reuse that entry's TR-ID unchanged.
2. **No match** → assign a new ID: next available `TR-[system]-NNN`.
3. **Ambiguous** → ask the user whether it refers to the same requirement.

For any requirement with `status: deprecated` in the registry — skip it.

For each GDD, extract all **technical requirements** — things the
architecture must provide for the system to work.

Categories to extract:

| Category | Example |
|----------|---------|
| **Data structures** | "Each entity has health, max health, status effects" |
| **Performance constraints** | "Collision detection must run at 60fps with 200 entities" |
| **Engine capability** | "Inverse kinematics for character animation" |
| **Cross-system communication** | "Damage system notifies UI and audio simultaneously" |
| **State persistence** | "Player progress persists between sessions" |
| **Threading/timing** | "AI decisions happen off the main thread" |
| **Platform requirements** | "Supports keyboard, gamepad, touch" |

For each GDD, produce a structured list:

```
GDD: [filename]
System: [system name]
Technical Requirements:
  TR-[GDD]-001: [requirement text] → Domain: [Physics/Rendering/etc]
  TR-[GDD]-002: [requirement text] → Domain: [...]
```

---

## Phase 3: Build the Traceability Matrix

For each technical requirement from Phase 2, search the ADRs:

1. Read every ADR's "GDD Requirements Addressed" section
2. Check if it explicitly references the requirement or its GDD
3. Check if the ADR's decision text implicitly covers the requirement
4. Mark coverage status:

| Status | Meaning |
|--------|---------|
| ✅ **Covered** | An ADR explicitly addresses this requirement |
| ⚠️ **Partial** | An ADR partially covers this, or coverage is ambiguous |
| ❌ **Gap** | No ADR addresses this requirement |

Build the full matrix:

```
## Traceability Matrix

| Requirement ID | GDD | System | Requirement | ADR Coverage | Status |
|---------------|-----|--------|-------------|--------------|--------|
| TR-combat-001 | combat.md | Combat | Hitbox detection < 1 frame | ADR-0003 | ✅ |
| TR-combat-002 | combat.md | Combat | Combo window timing | — | ❌ GAP |
```

Count the totals: X covered, Y partial, Z gaps.

---

## Phase 3b: Story and Test Linkage (RTM mode only)

*Skip this phase unless the argument is `rtm` or `full` with stories present.*

### Step 3b-1 — Load stories

Use `file_search` for `production/epics/**/*.md` (excluding EPIC.md). For each story:
- Extract `TR-ID` from the story's Context section
- Extract story file path, title, Status
- Extract `## Test Evidence` section — the stated test file path

### Step 3b-2 — Load test files

Use `file_search` for `tests/unit/**/*_test.*` and `tests/integration/**/*_test.*`.
Build an index: system → [test file paths].

For each test file path from Step 3b-1, confirm via `file_search` whether the file
actually exists. Note MISSING if not found.

### Step 3b-3 — Build the extended RTM

For each TR-ID in the Phase 3 matrix, add:
- **Story**: story file path(s) referencing this TR-ID
- **Test File**: test file path from story's Test Evidence section
- **Test Status**: COVERED / MISSING / NONE / NO STORY

---

## Phase 4: Cross-ADR Conflict Detection

Compare every ADR against every other ADR to detect contradictions:

- **Data ownership conflict**: Two ADRs claim exclusive ownership of the same data
- **Integration contract conflict**: ADR-A assumes System X has interface Y, but
  ADR-B defines System X with a different interface
- **Performance budget conflict**: ADR-A allocates N ms to physics, ADR-B allocates
  N ms to AI, together they exceed the total frame budget
- **Dependency cycle**: ADR-A says System X initialises before Y; ADR-B says Y before X
- **Architecture pattern conflict**: ADR-A uses event-driven communication; ADR-B
  uses direct function calls to the same subsystem
- **State management conflict**: Two ADRs define authority over the same game state

For each conflict:

```
## Conflict: [ADR-NNNN] vs [ADR-MMMM]
Type: [Data ownership / Integration / Performance / Dependency / Pattern / State]
ADR-NNNN claims: [...]
ADR-MMMM claims: [...]
Impact: [What breaks if both are implemented as written]
Resolution options:
  1. [Option A]
  2. [Option B]
```

### ADR Dependency Ordering

1. **Collect all `Depends On` fields** from every ADR's "ADR Dependencies" section
2. **Topological sort**: Determine correct implementation order
3. **Flag unresolved dependencies**: If ADR-A depends on a Proposed or nonexistent ADR
4. **Cycle detection**: Flag `DEPENDENCY CYCLE` if found
5. **Output recommended implementation order** (topologically sorted)

---

## Phase 5: Engine Compatibility Cross-Check

### Version Consistency
- Do all ADRs mention the same engine version?
- Flag ADRs written for older versions as potentially stale

### Post-Cutoff API Consistency
- Collect all "Post-Cutoff APIs Used" fields
- Verify against module reference docs
- Check for contradictory assumptions about the same API

### Deprecated API Check
- Use `grep_search` across all ADRs for API names listed in `deprecated-apis.md`

### Missing Engine Compatibility Sections
- List ADRs missing the Engine Compatibility section entirely

### Engine Specialist Consultation

Spawn the **primary engine specialist** (e.g. `cc-godot-specialist`, `cc-unity-specialist`, or `cc-unreal-specialist`) via `runSubagent` with all ADRs that contain engine-specific decisions. Ask them to:
1. Confirm or challenge each audit finding
2. Identify engine-specific anti-patterns the audit missed
3. Flag ADRs with incorrect assumptions about the pinned version

Incorporate findings under `### Engine Specialist Findings`.

---

## Phase 5b: Design Revision Flags (Architecture → GDD Feedback)

For each **HIGH RISK engine finding** from Phase 5, check whether any GDD makes an
assumption that the verified engine reality contradicts.

For each conflict found, record it:

```
### GDD Revision Flags (Architecture → Design Feedback)

| GDD | Assumption | Reality (from ADR/engine-reference) | Action |
|-----|-----------|--------------------------------------|--------|
| combat.md | "Use HingeJoint3D damp for weapon recoil" | Jolt ignores damp — ADR-0003 | Revise GDD |
```

If no flags: "No GDD revision flags — all GDD assumptions consistent with verified engine behaviour."

---

## Phase 6: Architecture Document Coverage

If `docs/architecture/architecture.md` exists, validate it against GDDs:

- Does every system from `systems-index.md` appear in the architecture layers?
- Does the data flow section cover all cross-system communication?
- Do the API boundaries support all integration requirements?
- Are there orphaned architecture entries with no GDD?

---

## Phase 7: Output the Review Report

```
## Architecture Review Report
Date: [date]
Engine: [name + version]
GDDs Reviewed: [N]
ADRs Reviewed: [M]

---

### Traceability Summary
Total requirements: [N]
✅ Covered: [X]
⚠️ Partial: [Y]
❌ Gaps: [Z]

### Coverage Gaps (no ADR exists)
  ❌ TR-[id]: [GDD] → [system] → [requirement]
     Suggested ADR: "/cc-architecture-decision [suggested title]"

### Cross-ADR Conflicts
[List all conflicts from Phase 4]

### ADR Dependency Order
[Topologically sorted implementation order]

### GDD Revision Flags
[From Phase 5b]

### Engine Compatibility Issues
[From Phase 5]

### Architecture Document Coverage
[From Phase 6]

---

### Verdict: [PASS / CONCERNS / FAIL]

PASS: All requirements covered, no conflicts, engine consistent
CONCERNS: Some gaps or partial coverage, but no blocking conflicts
FAIL: Critical gaps or blocking cross-ADR conflicts detected
```

---

## Phase 8: Write and Update Traceability Index

Use `vscode_askQuestions` for the write approval:
- "Review complete. What would you like to write?"
  - [A] Write all three files (review report + traceability index + TR registry)
  - [B] Write review report only
  - [C] Don't write anything yet

### RTM Output (rtm mode only)

Additionally write `docs/architecture/requirements-traceability.md` with the full matrix.

### TR Registry Update

Also ask: "May I update `docs/architecture/tr-registry.yaml` with new requirement IDs?"

If yes:
- **Append** new TR-IDs
- **Update** `requirement` text for changed GDD wording (ID stays the same)
- **Mark** `status: deprecated` for removed requirements (confirm with user)
- **Never** renumber or delete existing entries

### Reflexion Log Update

After writing, append any 🔴 CONFLICT entries to `docs/consistency-failures.md` (if it exists).

### Session State Update

Silently append to `production/session-state/active.md`:

    ## Session Extract — /cc-architecture-review [date]
    - Verdict: [PASS / CONCERNS / FAIL]
    - Requirements: [N] total — [X] covered, [Y] partial, [Z] gaps
    - New TR-IDs registered: [N, or "None"]
    - GDD revision flags: [names, or "None"]
    - Report: docs/architecture/architecture-review-[date].md

---

## Phase 9: Handoff

Present:
1. **Immediate actions**: List the top 3 ADRs to create (highest-impact gaps first)
2. **Gate guidance**: "When all blocking issues are resolved, run `/cc-gate-check pre-production` to advance"
3. **Rerun trigger**: "Re-run `/cc-architecture-review` after each new ADR is written"

Close with `vscode_askQuestions`:
- "Architecture review complete. What would you like to do next?"
  - [A] Write a missing ADR — run `/cc-architecture-decision [system]`
  - [B] Run `/cc-gate-check pre-production` — if all blocking gaps are resolved
  - [C] Stop here for this session

---

## Error Recovery Protocol

If any spawned agent returns BLOCKED, errors, or fails to complete:

1. Surface immediately: "[AgentName]: BLOCKED — [reason]"
2. Assess dependencies: do not proceed past dependent phases without user input
3. Offer options via `vscode_askQuestions`:
   - Skip this agent and note the gap
   - Retry with narrower scope
   - Stop here and resolve the blocker first
4. Always produce a partial report — output whatever was completed

---

## Collaborative Protocol

1. **Read silently** — do not narrate every file read
2. **Show the matrix** — present the full traceability matrix before asking anything
3. **Don't guess** — if a requirement is ambiguous, ask the user
4. **Ask before writing** — always confirm before writing the report file
5. **Non-blocking** — the verdict is advisory; the user decides whether to continue
