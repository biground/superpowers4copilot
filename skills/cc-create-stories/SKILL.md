---
name: cc-create-stories
description: "Break a single epic into implementable story files. Reads the epic, its GDD, governing ADRs, and control manifest. Each story embeds its GDD requirement TR-ID, ADR guidance, acceptance criteria, story type, and test evidence path. Run after /cc-create-epics for each epic."
---

# Create Stories

A story is a single implementable behaviour — small enough to complete in one
focused session, self-contained, and fully traceable to a GDD requirement and
an ADR decision.

**Run this skill per epic**, not per layer. Foundation epics first, then Core.

**Output:** `production/epics/[epic-slug]/story-NNN-[slug].md` files

**Previous step:** `/cc-create-epics [system]`
**Next step:** `/cc-story-readiness [story-path]` then `/cc-dev-story [story-path]`

---

## 1. Parse Argument

Resolve review mode:
1. If `--review [full|lean|solo]` was passed → use that
2. Else use `file_search` to find `**/review-mode.txt`, then `read_file` → use that value
3. Else → default to `lean`

- `/cc-create-stories [epic-slug]`
- `/cc-create-stories production/epics/combat/EPIC.md` — full path also accepted
- No argument — ask: "Which epic?" Use `file_search` for `production/epics/*/EPIC.md` and list available epics.

---

## 2. Load Everything for This Epic

Use `read_file` on:

- `production/epics/[epic-slug]/EPIC.md`
- The epic's GDD (`design/gdd/[filename].md`) — all 8 sections
- All governing ADRs — Decision, Implementation Guidelines, Engine Compatibility, Engine Notes
- `docs/architecture/control-manifest.md` — extract rules for this layer; note Manifest Version
- `docs/architecture/tr-registry.yaml` — load all TR-IDs for this system

**ADR existence validation**: Confirm each ADR file exists. If any is missing, stop:
> "Epic references [ADR-NNNN] but file not found. Cannot create stories until all ADR files are present."

Report: "Loaded epic [name], GDD [filename], [N] governing ADRs (all confirmed present), control manifest v[date]."

---

## 3. Classify Stories by Type

| Story Type | Assign when criteria reference... |
|---|---|
| **Logic** | Formulas, numerical thresholds, state transitions, calculations |
| **Integration** | Two+ systems interacting, signals crossing boundaries, save/load |
| **Visual/Feel** | Animation behaviour, VFX, timing, screen shake, audio sync |
| **UI** | Menus, HUD elements, buttons, screens, tooltips |
| **Config/Data** | Balance tuning values, data file changes only |

Mixed stories: assign the type with highest implementation risk.

---

## 4. Decompose the GDD into Stories

For each GDD acceptance criterion:

1. Group related criteria requiring the same core implementation
2. Each group = one story
3. Order: foundational behaviour first, edge cases last, UI last

**Story sizing rule:** one story = one focused session (~2-4 hours).

For each story, determine:
- **GDD requirement**: which acceptance criterion(ia)
- **TR-ID**: from `tr-registry.yaml`. If no match, use `TR-[system]-???` and warn.
- **Governing ADR**: `Status: Accepted` → embed normally. `Status: Proposed` → story `Status: Blocked`
- **Story Type**: from Step 3
- **Engine risk**: from ADR's Knowledge Risk

---

## 4b. QA Lead Story Readiness Gate

**Review mode check**:
- `solo` → skip. Proceed to Step 5.
- `lean` → skip. Proceed to Step 5.
- `full` → spawn `cc-qa-tester` via `runSubagent` to review acceptance criteria testability.

For each story flagged as GAPS or INADEQUATE, revise before proceeding.

**After ADEQUATE**: for Logic and Integration stories, produce concrete test case specs:

```
Test: [criterion text]
  Given: [precondition]
  When: [action]
  Then: [expected result / assertion]
  Edge cases: [boundary values or failure states]
```

For Visual/Feel and UI stories, produce manual verification steps:
```
Manual check: [criterion text]
  Setup: [how to reach the state]
  Verify: [what to look for]
  Pass condition: [unambiguous pass description]
```

---

## 5. Present Stories for Review

Before writing, present the full story list:

```
## Stories for Epic: [name]

Story 001: [title] — Logic — ADR-NNNN
  Covers: TR-[system]-001
  Test required: tests/unit/[system]/[slug]_test.[ext]

Story 002: [title] — Integration — ADR-MMMM
  Covers: TR-[system]-002, TR-[system]-003
  Test required: tests/integration/[system]/[slug]_test.[ext]

[N stories total: N Logic, N Integration, N Visual/Feel, N UI, N Config/Data]
```

Use `vscode_askQuestions`:
- "May I write these [N] stories to `production/epics/[epic-slug]/`?"
- Options: `[A] Yes — write all` / `[B] Not yet — review first`

---

## 6. Write Story Files

For each story, use `create_file` on `production/epics/[epic-slug]/story-[NNN]-[slug].md`:

```markdown
# Story [NNN]: [title]

> **Epic**: [epic name]
> **Status**: Ready
> **Layer**: [Foundation / Core / Feature / Presentation]
> **Type**: [Logic | Integration | Visual/Feel | UI | Config/Data]
> **Manifest Version**: [date from control-manifest.md header]

## Context

**GDD**: `design/gdd/[filename].md`
**Requirement**: `TR-[system]-NNN`

**ADR Governing Implementation**: [ADR-NNNN: title]
**ADR Decision Summary**: [1-2 sentence summary]

**Engine**: [name + version] | **Risk**: [LOW / MEDIUM / HIGH]
**Engine Notes**: [from ADR Engine Compatibility section]

**Control Manifest Rules (this layer)**:
- Required: [relevant required pattern]
- Forbidden: [relevant forbidden pattern]
- Guardrail: [relevant performance guardrail]

---

## Acceptance Criteria

- [ ] [criterion 1 — from GDD]
- [ ] [criterion 2]

---

## Implementation Notes

[Specific, actionable guidance from the ADR Implementation Guidelines.]

---

## Out of Scope

- [Story NNN+1]: [what it handles]

---

## QA Test Cases

**[Logic/Integration — automated]:**
- **AC-1**: [criterion]
  - Given: [precondition]
  - When: [action]
  - Then: [assertion]
  - Edge cases: [boundary values]

**[Visual/Feel/UI — manual]:**
- **AC-1**: [criterion]
  - Setup: [how to reach the state]
  - Verify: [what to look for]
  - Pass condition: [description]

---

## Test Evidence

**Story Type**: [type]
**Required evidence**:
- Logic: `tests/unit/[system]/[story-slug]_test.[ext]`
- Integration: `tests/integration/[system]/[story-slug]_test.[ext]`
- Visual/Feel: `production/qa/evidence/[story-slug]-evidence.md`
- UI: `production/qa/evidence/[story-slug]-evidence.md`
- Config/Data: smoke check pass

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: [Story NNN-1 or "None"]
- Unlocks: [Story NNN+1 or "None"]
```

### Also update `production/epics/[epic-slug]/EPIC.md`

Replace "Stories: Not yet created" with a populated story table.

---

## 7. After Writing

Use `vscode_askQuestions`:
- "[N] stories written. What next?"
- Options (include all that apply):
  - `[A] Start implementing — run /cc-story-readiness [first-story-path]` (Recommended)
  - `[B] Create stories for [next-epic-slug]` (if other epics lack stories)
  - `[C] Plan the sprint — run /cc-sprint-plan` (if all epics have stories)
  - `[D] Stop here`

---

## Collaborative Protocol

1. **Read before presenting** — load all inputs silently before showing the story list
2. **Ask once** — present all stories in one summary, not one at a time
3. **Warn on blocked stories** — flag any story with a Proposed ADR
4. **Ask before writing** — get approval for the full story set
5. **No invention** — acceptance criteria from GDDs, implementation notes from ADRs
6. **Never start implementation** — this skill stops at the story file level
