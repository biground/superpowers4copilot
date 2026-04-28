---
name: cc-create-control-manifest
description: "After architecture is complete, produces a flat actionable rules sheet for programmers — what you must do, what you must never do, per system and per layer. Extracted from all Accepted ADRs, technical preferences, and engine reference docs."
---

# Create Control Manifest

The Control Manifest is a flat, actionable rules sheet for programmers. It
answers "what do I do?" and "what must I never do?" — organized by architectural
layer, extracted from all Accepted ADRs, technical preferences, and engine
reference docs. Where ADRs explain *why*, the manifest tells you *what*.

**Output:** `docs/architecture/control-manifest.md`

**When to run:** After `/cc-architecture-review` passes and ADRs are in Accepted
status. Re-run whenever new ADRs are accepted or existing ADRs are revised.

---

## 1. Load All Inputs

### ADRs
- Use `file_search` for `docs/architecture/adr-*.md` and `read_file` every file
- Filter to only Accepted ADRs (Status: Accepted) — skip Proposed, Deprecated, Superseded
- Note the ADR number and title for every rule sourced

### Technical Preferences
- Read the project technical preferences file
- Extract: naming conventions, performance budgets, approved libraries/addons, forbidden patterns

### Engine Reference
- Use `read_file` on `docs/engine-reference/[engine]/VERSION.md`
- Use `read_file` on `docs/engine-reference/[engine]/deprecated-apis.md`
- Use `read_file` on `docs/engine-reference/[engine]/current-best-practices.md` if it exists

Report: "Loaded [N] Accepted ADRs, engine: [name + version]."

---

## 2. Extract Rules from Each ADR

For each Accepted ADR, extract:

### Required Patterns (from "Implementation Guidelines" section)
- Every "must", "should", "required to", "always" statement
- Every specific pattern or approach mandated

### Forbidden Approaches (from "Alternatives Considered" sections)
- Every alternative that was explicitly rejected — *why* it was rejected becomes
  the rule ("never use X because Y")
- Any anti-patterns explicitly called out

### Performance Guardrails (from "Performance Implications" section)
- Budget constraints: "max N ms per frame for this system"
- Memory limits: "this system must not exceed N MB"

### Engine API Constraints (from "Engine Compatibility" section)
- Post-cutoff APIs that require verification
- Verified behaviours that differ from default LLM assumptions

### Layer Classification
Classify each rule by the architectural layer:
- **Foundation**: Scene management, event architecture, save/load, engine init
- **Core**: Core gameplay loops, main player systems, physics/collision
- **Feature**: Secondary systems, secondary mechanics, AI
- **Presentation**: Rendering, audio, UI, VFX, shaders

If an ADR spans multiple layers, duplicate the rule into each relevant layer.

---

## 3. Add Global Rules

### From technical-preferences:
- Naming conventions, performance budgets

### From deprecated-apis.md:
- All deprecated APIs → Forbidden API entries

### From current-best-practices.md (if available):
- Engine-recommended patterns → Required entries

---

## 4. Present Rules Summary Before Writing

```
## Control Manifest Preview
Engine: [name + version]
ADRs covered: [list ADR numbers]
Total rules extracted:
  - Foundation layer: [N] required, [M] forbidden, [P] guardrails
  - Core layer: [N] required, [M] forbidden, [P] guardrails
  - Feature layer: ...
  - Presentation layer: ...
  - Global: [N] naming conventions, [M] forbidden APIs, [P] approved libraries
```

Ask: "Does this look complete? Any rules to add or remove before I write the manifest?"

---

## 4b. Director Gate — Technical Review

**Review mode check**:
- `solo` → skip. Proceed to Phase 5.
- `lean` → skip. Proceed to Phase 5.
- `full` → spawn as normal.

Spawn `cc-technical-director` (if available, or `cc-lead-programmer`) via `runSubagent` to review whether:
- All mandatory ADR patterns are captured and accurately stated
- Forbidden approaches are complete and correctly attributed
- No rules were added that lack a source ADR or preference document
- Performance guardrails are consistent with the ADR constraints

Apply the verdict:
- **APPROVE** → proceed to Phase 5
- **CONCERNS** → surface via `vscode_askQuestions`
- **REJECT** → fix flagged rules and re-present

---

## 5. Write the Control Manifest

Ask: "May I write this to `docs/architecture/control-manifest.md`?"

Format:

```markdown
# Control Manifest

> **Engine**: [name + version]
> **Last Updated**: [date]
> **Manifest Version**: [date]
> **ADRs Covered**: [ADR-NNNN, ADR-MMMM, ...]
> **Status**: Active — regenerate with `/cc-create-control-manifest update` when ADRs change

---

## Foundation Layer Rules

*Applies to: scene management, event architecture, save/load, engine initialisation*

### Required Patterns
- **[rule]** — source: [ADR-NNNN]

### Forbidden Approaches
- **Never [anti-pattern]** — [brief reason] — source: [ADR-NNNN]

### Performance Guardrails
- **[system]**: max [N]ms/frame — source: [ADR-NNNN]

---

## Core Layer Rules

*Applies to: core gameplay loop, main player systems, physics, collision*

[Same structure]

---

## Feature Layer Rules

[Same structure]

---

## Presentation Layer Rules

[Same structure]

---

## Global Rules

### Naming Conventions
[From technical-preferences]

### Forbidden APIs
[From deprecated-apis.md]

### Approved Libraries
[From technical-preferences]
```

Use `create_file` to write the manifest.

---

## 6. Close

Use `vscode_askQuestions`:
- "Control manifest written. What's next?"
  - [A] Create epics — run `/cc-create-epics`
  - [B] Stop here
