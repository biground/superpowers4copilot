---
name: cc-reverse-document
description: "Generate design or architecture documents from existing implementation. Works backwards from code/prototypes to create missing planning docs."
---

# Reverse Documentation

This skill analyzes existing implementation (code, prototypes, systems) and generates
appropriate design or architecture documentation. Use this when:
- You built a feature without writing a design doc first
- You inherited a codebase without documentation
- You prototyped a mechanic and need to formalize it
- You need to document "why" behind existing code

---

## Workflow

## Phase 1: Parse Arguments

**Format**: `/cc-reverse-document <type> <path>`

**Type options**:
- `design` → Generate a game design document (GDD section)
- `architecture` → Generate an Architecture Decision Record (ADR)
- `concept` → Generate a concept document from prototype

**Path**: Directory or file to analyze
- `src/gameplay/combat/` → All combat-related code
- `src/core/event-system.cpp` → Specific file
- `prototypes/stealth-mech/` → Prototype directory

**Examples**:
```bash
/cc-reverse-document design src/gameplay/magic-system
/cc-reverse-document architecture src/core/entity-component
/cc-reverse-document concept prototypes/vehicle-combat
```

## Phase 2: Analyze Implementation

Use `read_file`, `grep_search`, `file_search`, and `list_dir` to read and understand the code/prototype:

**For design docs (GDD):**
- Identify mechanics, rules, formulas
- Extract gameplay values (damage, cooldowns, ranges)
- Find state machines, ability systems, progression
- Detect edge cases handled in code
- Map dependencies (what systems interact?)

**For architecture docs (ADR):**
- Identify patterns (ECS, singleton, observer, etc.)
- Understand technical decisions (threading, serialization, etc.)
- Map dependencies and coupling
- Assess performance characteristics
- Find constraints and trade-offs

**For concept docs (prototype analysis):**
- Identify core mechanic
- Extract emergent gameplay patterns
- Note what worked vs what didn't
- Find technical feasibility insights
- Document player fantasy / feel

## Phase 3: Ask Clarifying Questions

**DO NOT** just describe the code. **ASK** about intent using `vscode_askQuestions`:

**Design questions**:
- "I see a [resource] system that depletes during [activity]. Was this for pacing, resource management, or something else?"
- "The [mechanic] seems central. Is this a core pillar, or supporting feature?"
- "[Value] scales exponentially with [factor]. Intentional design, or needs rebalancing?"

**Architecture questions**:
- "You're using a service locator pattern. Was this chosen for testability, decoupling, or inherited from existing code?"
- "I see manual memory management instead of smart pointers. Performance requirement, or legacy?"

**Concept questions**:
- "The prototype emphasizes stealth over combat. Is that the intended pillar?"
- "Players seem to exploit the grappling hook for speed. Feature or bug?"

## Phase 4: Present Findings

Before drafting, show what you discovered:

```
I've analyzed [path]/. Here's what I found:

MECHANICS IMPLEMENTED:
- [mechanic-a] with [property]
- [mechanic-b]
- [resource] system (depletes on [action], regens on [condition])

FORMULAS DISCOVERED:
- [Output] = [formula using discovered variables]

UNCLEAR INTENT AREAS:
1. [Resource] system — pacing or resource management?
2. [Mechanic] — core pillar or supporting feature?
3. [Value] scaling — intentional design or needs tuning?

Before I draft the design doc, could you clarify these points?
```

Wait for user to clarify intent before drafting.

## Phase 5: Draft Document Using Template

Based on type, use appropriate template:

| Type | Output Path |
|------|-------------|
| `design` | `design/gdd/[system-name].md` |
| `architecture` | `docs/architecture/[decision-name].md` |
| `concept` | `prototypes/[name]/CONCEPT.md` or `design/concepts/[name].md` |

**Draft structure**:
- Capture **what exists** (mechanics, patterns, implementation)
- Document **why it exists** (intent clarified with user)
- Identify **what's missing** (edge cases not handled, gaps in design)
- Flag **follow-up work** (balance tuning, missing features)

## Phase 6: Show Draft and Request Approval

Use `vscode_askQuestions`:
```
I've drafted the [system-name] design doc based on your code and clarifications.

ADDITIONS I MADE:
- Documented [mechanic] as "[intent]" per your clarification
- Added edge cases not in code
- Flagged balance concern: [scaling type] scaling at [boundary condition]

SECTIONS MARKED AS INCOMPLETE:
- "[System] interaction with [other-system]" (not fully implemented yet)

May I write this to design/gdd/[system-name].md?
```
- Options: "Yes — write the document", "Show full preview first", "Cancel"

Wait for approval. User may request changes before writing.

## Phase 7: Write Document with Metadata

When approved, use `create_file` to write the file with special markers:

```markdown
---
status: reverse-documented
source: [path/]
date: [today]
verified-by: [User name]
---

# [System Name] Design

> **Note**: This document was reverse-engineered from the existing implementation.
> It captures current behavior and clarified design intent. Some sections may be
> incomplete where implementation is partial or intent was unclear.

[Rest of document...]
```

## Phase 8: Flag Follow-Up Work

After writing, suggest next steps:

```
Written to design/gdd/[system-name].md

FOLLOW-UP RECOMMENDED:
1. Run /cc-balance-check on discovered formulas
2. Create ADR for architecture decision via /cc-architecture-decision
3. Implement missing edge cases
4. Extend design doc when additional features are implemented

Would you like me to tackle any of these now?
```

---

## Template Selection Logic

| If analyzing... | Output type | Because... |
|----------------|-------------|------------|
| `src/gameplay/*` | design GDD | Gameplay mechanics → GDD |
| `src/core/*`, `src/ai/*` | architecture ADR | Core systems → ADR |
| `prototypes/*` | concept doc | Experiments → concept doc |
| `src/networking/*` | architecture ADR | Technical systems → ADR |
| `src/ui/*` | design spec | UI/UX → design spec |

---

## Collaborative Protocol

This skill follows the collaborative design principle:

1. **Analyze First**: Read code, understand implementation
2. **Question Intent**: Ask about "why", not just "what"
3. **Present Findings**: Show discoveries, highlight unclear areas
4. **User Clarifies**: Separate intent from accidents
5. **Draft Document**: Create doc based on reality + intent
6. **Show Draft**: Display key sections, explain additions
7. **Get Approval**: "May I write to [filepath]?" On approval: Verdict: **COMPLETE** — document generated. On decline: Verdict: **BLOCKED** — user declined write.
8. **Flag Follow-Up**: Suggest related work, don't auto-execute

**Never assume intent. Always ask before documenting "why".**
