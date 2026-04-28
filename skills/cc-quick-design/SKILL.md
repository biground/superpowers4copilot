---
name: cc-quick-design
description: "Lightweight design spec for small changes — tuning adjustments, minor mechanics, balance tweaks. Skips full GDD authoring when a system GDD already exists or the change is too small to warrant one. Produces a Quick Design Spec that embeds directly into story files."
---

# Quick Design

This is the **lightweight design path** for changes that don't need a full GDD.
Full GDD authoring via `/cc-design-system` is the heavyweight path. Use this skill
for work under approximately 4 hours of implementation.

**Output:** `design/quick-specs/[name]-[date].md`

---

## 1. Classify the Change

Read the argument and determine the category:

- **Tuning** — changing numbers/balance values, no behavioral change
- **Tweak** — small behavioral change, no new states or systems
- **Addition** — adding a small mechanic, 1-2 new states or interactions
- **New Small System** — standalone feature, under ~1 week implementation

If the change doesn't fit these categories, redirect to `/cc-design-system`.

Present the classification. If no argument, ask the user to describe the change.

---

## 2. Context Scan

Use `file_search` and `read_file` on relevant context:

- Search `design/gdd/` for the most relevant GDD. Read affected sections.
- Check `design/gdd/systems-index.md` if it exists — understand dependencies and tier.
- Check `design/quick-specs/` for prior quick specs on this system — avoid contradictions.
- For Tuning changes, also check `assets/data/` for the data file with relevant values.

Report what was found.

---

## 3. Draft the Quick Design Spec

### For Tuning changes

```markdown
# Quick Design Spec: [Title]

**Type**: Tuning
**System**: [System name]
**GDD Reference**: `design/gdd/[filename].md` — Tuning Knobs section
**Date**: [today]

## Change

| Parameter | Old Value | New Value | Rationale |
|-----------|-----------|-----------|-----------|
| [param]   | [old]     | [new]     | [why]     |

## Tuning Knob Mapping

Maps to GDD Tuning Knob: [knob name and documented range].
New value is [within / at the edge of / outside] the documented range.

## Acceptance Criteria

- [ ] [Parameter] reads [new value] from `assets/data/[file]`
- [ ] Behavior difference is observable in [specific context]
- [ ] No regression in [related behavior]
```

### For Tweak and Addition changes

```markdown
# Quick Design Spec: [Title]

**Type**: [Tweak / Addition]
**System**: [System name]
**GDD Reference**: `design/gdd/[filename].md`
**Date**: [today]

## Change Summary
[1-2 sentences.]

## Motivation
[Why needed? What player experience problem does it solve?]

## Design Delta

Current GDD says:
> [exact quote]

This spec changes that to:
[New rule or description.]

## New Rules / Values
[Unambiguous statement. List new states, parameters, ranges.]

## Affected Systems
| System | Impact | Action Required |

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] No regression: [original behavior must not break]

## GDD Update Required?
[Yes / No. If yes: which file, which section, what update.]
```

### For New Small System changes

```markdown
# Quick Design Spec: [Title]

**Type**: New Small System
**Scope**: [1-2 sentence description]
**Date**: [today]
**Estimated Implementation**: [hours]

## Overview
[What does this system do, when does it activate, what does it produce?]

## Core Rules
[Precise rules for implementation.]

## Tuning Knobs
| Knob | Default | Range | Category | Rationale |

All values must live in `assets/data/[file].json`, not hardcoded.

## Acceptance Criteria
- [ ] [Functional criterion]
- [ ] [Edge case criterion]
- [ ] [Experiential criterion]
- [ ] [Regression criterion]

## Systems Index
[Should it be added? If too small: "Below tracking threshold."]
```

---

## 4. Approval and Filing

Present the draft in full. Then ask:

"May I write this Quick Design Spec to `design/quick-specs/[kebab-case-title]-[YYYY-MM-DD].md`?"

Use `create_file` to write. Create `design/quick-specs/` if it doesn't exist.

If a GDD update is required, ask separately after writing. Show the exact text change (old vs. new) before asking. Use `replace_string_in_file` for GDD edits only with explicit approval.

---

## 5. Handoff

```
Quick Design Spec written to: design/quick-specs/[filename].md
Type: [Tuning / Tweak / Addition / New Small System]
System: [system name]
GDD update: [Required — pending / Applied / Not required]

Next step: Reference this spec in the story's GDD Reference field.
Run /cc-story-readiness then /cc-dev-story to implement.
```

Quick Design Specs **bypass** `/cc-design-review` and `/cc-review-all-gdds` by design.

Redirect to `/cc-design-system` if:
- Change adds a new system that belongs in the systems index
- Change significantly alters cross-system behavior
- Change introduces new player-facing mechanics affecting MDA aesthetic balance
- Implementation likely to exceed one week
