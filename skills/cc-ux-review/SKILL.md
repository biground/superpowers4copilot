---
name: cc-ux-review
description: "Validates a UX spec, HUD design, or interaction pattern library for completeness, accessibility compliance, GDD alignment, and implementation readiness. Produces APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED verdict with specific gaps."
---

## Overview

Validates UX design documents before they enter the implementation pipeline.
Acts as the quality gate between UX Design and Visual Design/Implementation in
the `/cc-team-ui` pipeline.

**Run this skill:**
- After completing a UX spec with `/cc-ux-design`
- Before handing off to `cc-ui-programmer` or `cc-art-director`
- Before the Pre-Production to Production gate check
- After major revisions to a UX spec

**Verdict levels:**
- **APPROVED** — spec is complete, consistent, and implementation-ready
- **NEEDS REVISION** — specific gaps found; fix before handoff but not a full redesign
- **MAJOR REVISION NEEDED** — fundamental issues; needs significant rework

---

## Phase 1: Parse Arguments

- **Specific file path** (e.g., `/cc-ux-review design/ux/inventory.md`): validate that one document
- **`all`**: use `file_search` for all files in `design/ux/` and validate each
- **`hud`**: validate `design/ux/hud.md` specifically
- **`patterns`**: validate `design/ux/interaction-patterns.md` specifically
- **No argument**: use `vscode_askQuestions` to ask which spec to validate

For `all`, output a summary table first (file | verdict | primary issue) then full detail for each.

---

## Phase 2: Load Cross-Reference Context

Before validating any spec, use `read_file` to load:

1. **Input & Platform config**: `.claude/docs/technical-preferences.md` — extract `## Input & Platform`.
2. `design/accessibility-requirements.md` (if it exists)
3. `design/ux/interaction-patterns.md` (if it exists)
4. The GDDs referenced in the spec's header (read their UI Requirements sections)
5. `design/player-journey.md` (if it exists)

---

## Phase 3A: UX Spec Validation Checklist

### Completeness (required sections)

- [ ] Document header present with Status, Author, Platform Target
- [ ] Purpose & Player Need — has a player-perspective need statement
- [ ] Player Context on Arrival — describes player's state and prior activity
- [ ] Navigation Position — shows where screen sits in hierarchy
- [ ] Entry & Exit Points — all entry sources and exit destinations documented
- [ ] Layout Specification — zones defined, component inventory table present
- [ ] States & Variants — at minimum: loading, empty/populated, and error states
- [ ] Interaction Map — covers all target input methods
- [ ] Data Requirements — every data element has a source system and owner
- [ ] Events Fired — every player action has a corresponding event or null explanation
- [ ] Transitions & Animations — at least enter/exit transitions specified
- [ ] Accessibility Requirements — screen-level requirements present
- [ ] Localization Considerations — max character counts for text elements
- [ ] Acceptance Criteria — at least 5 specific testable criteria

### Quality Checks

**Player Need Clarity**
- [ ] Purpose written from player perspective, not system/developer perspective
- [ ] Player goal on arrival is unambiguous
- [ ] Player context on arrival is specific

**Completeness of States**
- [ ] Error state documented
- [ ] Empty state documented
- [ ] Loading state documented if screen fetches async data
- [ ] Timer/auto-dismiss states documented with duration

**Input Method Coverage**
- [ ] If platform includes PC: keyboard-only navigation fully specified
- [ ] If platform includes console/gamepad: d-pad navigation and face button mapping documented
- [ ] No interaction requires mouse-like precision on gamepad
- [ ] Focus order defined

**Data Architecture**
- [ ] No data element has "UI" listed as the owner
- [ ] Update frequency specified for all real-time data
- [ ] Null handling specified for all data elements

**Accessibility**
- [ ] Accessibility tier matched or exceeded
- [ ] If Basic tier: no color-only information indicators
- [ ] If Standard tier+: focus order documented, text contrast ratios specified
- [ ] If Comprehensive tier+: screen reader announcements for key state changes
- [ ] Colorblind check: color-coded elements have non-color alternatives

**GDD Alignment**
- [ ] Every GDD UI Requirement referenced in header is addressed
- [ ] No UI element displays/modifies game state without a GDD requirement
- [ ] No GDD UI Requirement is missing

**Pattern Library Consistency**
- [ ] All interactive components reference the pattern library
- [ ] No pattern behavior re-specified from scratch if already in library
- [ ] New patterns flagged for addition to library

**Localization**
- [ ] Character limit warnings present for text-heavy elements
- [ ] Layout-critical text flagged for 40% expansion accommodation

**Acceptance Criteria Quality**
- [ ] Criteria specific enough for a QA tester without design docs
- [ ] Performance criterion present
- [ ] Resolution criterion present
- [ ] No criterion requires reading another document

---

## Phase 3B: HUD Validation Checklist

### Completeness
- [ ] HUD Philosophy defined
- [ ] Information Architecture covers ALL systems with UI Requirements
- [ ] Layout Zones defined with safe zone margins
- [ ] Every HUD element fully specified
- [ ] HUD States by Gameplay Context covers: exploration, combat, dialogue/cutscene, paused
- [ ] Visual Budget defined
- [ ] Platform Adaptation covers all target platforms
- [ ] Tuning Knobs present

### Quality Checks
- [ ] No HUD element covers center play area without visibility rule
- [ ] All GDD information items in HUD or categorized as "hidden/demand"
- [ ] Color-coded elements have colorblind variants
- [ ] Notification elements have queue/priority behavior
- [ ] Visual Budget compliance verified

### GDD Alignment
- [ ] All systems in systems-index with UI category have HUD representation or justified absence

---

## Phase 3C: Pattern Library Validation Checklist

- [ ] Pattern catalog index is current
- [ ] Standard control patterns specified (button, toggle, slider, dropdown, list, grid, modal, dialog, toast, tooltip, progress bar, input field, tab bar, scroll)
- [ ] Game-specific patterns needed by current specs are present
- [ ] Each pattern has: When to Use, When NOT to Use, states, accessibility, implementation notes
- [ ] Animation Standards table present
- [ ] Sound Standards table present
- [ ] No conflicting behaviors between patterns

---

## Phase 4: Output the Verdict

```markdown
## UX Review: [Document Name]
**Date**: [date]
**Reviewer**: cc-ux-review skill
**Document**: [file path]
**Platform Target**: [from header]
**Accessibility Tier**: [from header or accessibility-requirements.md]

### Completeness: [X/Y sections present]
- [x] Purpose & Player Need
- [ ] States & Variants — MISSING: error state not documented

### Quality Issues: [N found]
1. **[Issue title]** [BLOCKING / ADVISORY]
   - What's wrong: [specific description]
   - Where: [section name]
   - Fix: [specific action to take]

### GDD Alignment: [ALIGNED / GAPS FOUND]
- GDD [name] UI Requirements — [X/Y requirements covered]
- Missing: [list any uncovered GDD requirements]

### Accessibility: [COMPLIANT / GAPS / NON-COMPLIANT]
- Target tier: [tier]
- [list specific accessibility findings]

### Pattern Library: [CONSISTENT / INCONSISTENCIES FOUND]
- [findings]

### Verdict: APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED
**Blocking issues**: [N] — must be resolved before implementation
**Advisory issues**: [N] — recommended but not blocking

[For APPROVED]: This spec is ready for handoff to `/cc-team-ui` Phase 2
(Visual Design).

[For NEEDS REVISION]: Address the [N] blocking issues above, then re-run
`/cc-ux-review`.

[For MAJOR REVISION NEEDED]: The spec has fundamental gaps in [areas].
Recommend returning to `/cc-ux-design` to rework [sections].
```

---

## Phase 5: Collaborative Protocol

This skill is READ-ONLY — it never edits or writes files. It reports findings only.

After delivering the verdict:
- For **APPROVED**: suggest running `/cc-team-ui` to begin implementation
- For **NEEDS REVISION**: offer to help fix specific gaps via `vscode_askQuestions` — but do not auto-fix
- For **MAJOR REVISION NEEDED**: suggest returning to `/cc-ux-design`

Never block the user from proceeding — the verdict is advisory. Document risks, present findings, let the user decide.
