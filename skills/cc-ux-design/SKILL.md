---
name: cc-ux-design
description: "Guided, section-by-section UX spec authoring for a screen, flow, or HUD. Reads game concept, player journey, and relevant GDDs to provide context-aware design guidance. Produces ux-spec.md (per screen/flow) or hud-design.md using the studio templates."
---

When this skill is invoked:

## 1. Parse Arguments & Determine Mode

Three authoring modes exist based on the argument:

| Argument | Mode | Output file |
|----------|------|-------------|
| `hud` | HUD design | `design/ux/hud.md` |
| `patterns` | Interaction pattern library | `design/ux/interaction-patterns.md` |
| Any other value (e.g., `main-menu`, `inventory`) | UX spec for a screen or flow | `design/ux/[argument].md` |
| No argument | Ask the user | (see below) |

**If no argument is provided**, use `vscode_askQuestions`:
- "What are we designing today?"
  - Options: "A specific screen or flow (I'll name it)", "The game HUD", "The interaction pattern library", "I'm not sure — help me figure it out"

If the user types a screen name, normalize it to kebab-case for the filename.

---

## 2. Gather Context (Read Phase)

Read all relevant context **before** asking the user anything.

### 2a: Required Reads

- Use `read_file` to read `design/gdd/game-concept.md` — if missing, warn:
  > "No game concept found. Run `/cc-brainstorm` first."
  > Continue anyway if the user asks.

### 2b: Player Journey

Use `read_file` to read `design/player-journey.md` if it exists. Extract journey phase data.

### 2c: GDD UI Requirements

Use `file_search` for `design/gdd/*.md` and `grep_search` for `UI Requirements` sections. Read any GDD whose UI Requirements section references this screen.

### 2d: Existing UX Specs

Use `file_search` for `design/ux/*.md` and note which screens already have specs. For related screens, read their navigation/flow sections.

### 2e: Interaction Pattern Library

If `design/ux/interaction-patterns.md` exists, use `read_file` to read the pattern catalog index.

### 2f: Art Bible

Use `file_search` to check for `design/art/art-bible.md`. If found, read the visual direction section.

### 2g: Accessibility Requirements

Use `file_search` to check for `design/accessibility-requirements.md`. If found, read it.

### 2h: Input Method (from Project Config)

Use `read_file` to read `.claude/docs/technical-preferences.md` and extract the `## Input & Platform` section.

If unconfigured, use `vscode_askQuestions` once:
> "Input methods aren't configured yet. What does this game target?"
> Options: "Keyboard/Mouse only", "Gamepad only", "Both (PC + Console)", "Touch (mobile)", "All of the above"

### 2i: Present Context Summary

Present a brief summary to the user, then use `vscode_askQuestions`:
> "Anything else I should read before we start, or shall we proceed?"

---

## 2b. Retrofit Mode Detection

Before creating a skeleton, use `file_search` to check if the target output file already exists.

**If the file exists — retrofit mode:**
- Use `read_file` to read the file in full
- Present section status summary
- Skip Phase 3 — use `replace_string_in_file` to fill placeholders in-place

**If the file does not exist — fresh authoring mode:**
Proceed to Phase 3.

---

## 3. Create File Skeleton

Use `vscode_askQuestions`: "May I create the skeleton file at `design/ux/[filename].md`?"

If approved, use `create_file` to write the skeleton with `[To be designed]` placeholders for each section.

### Skeleton sections for UX Spec:
- Purpose & Player Need
- Player Context on Arrival
- Navigation Position
- Entry & Exit Points
- Layout Specification (Information Hierarchy, Layout Zones, Component Inventory, ASCII Wireframe)
- States & Variants
- Interaction Map
- Events Fired
- Transitions & Animations
- Data Requirements
- Accessibility
- Localization Considerations
- Acceptance Criteria
- Open Questions

### Skeleton sections for HUD Design:
- HUD Philosophy
- Information Architecture (Full Information Inventory, Categorization)
- Layout Zones
- HUD Elements
- Dynamic Behaviors
- Platform & Input Variants
- Accessibility
- Open Questions

### Skeleton sections for Interaction Pattern Library:
- Overview
- Pattern Catalog
- Patterns (individual entries)
- Gaps & Patterns Needed
- Open Questions

---

## 4. Section-by-Section Authoring

Walk through each section in order. For **each section**, follow this cycle:

```
Context  ->  Questions  ->  Options  ->  Decision  ->  Draft  ->  Approval  ->  Write
```

1. **Context**: State what this section needs and surface constraints from Phase 2.
2. **Questions**: Use `vscode_askQuestions` for constrained choices, conversational text for open-ended exploration.
3. **Options**: Present 2-4 approaches with pros/cons.
4. **Decision**: User picks an approach.
5. **Draft**: Write the section content in conversation for review.
6. **Approval**: "Does this capture it? Any changes before I write?"
7. **Write**: Use `replace_string_in_file` to replace the `[To be designed]` placeholder.

### Section Guidance: UX Spec Mode

#### Section A: Purpose & Player Need
Ask: "What player goal does this screen serve?"

#### Section B: Player Context on Arrival
Ask: "When in the game does a player first encounter this screen?"

#### Section B2: Navigation Position
Ask: "Is this screen accessed from the main menu, pause, gameplay, or another screen?"

#### Section B3: Entry & Exit Points
Map every entry source and exit destination.

#### Section C: Layout Specification
Work through sub-sections: Information Hierarchy → Layout Zones → Component Inventory → ASCII Wireframe.

#### Section D: States & Variants
Guide the user beyond the happy path: empty state, error state, loading state, progression states.

#### Section E: Interaction Map
For each interactive component, define action, input mapping, feedback, and outcome. Use input methods from Phase 2h.

#### Section E2: Events Fired
For every action, document the corresponding event or explicitly note "no event."

#### Section E3: Transitions & Animations
Specify enter/exit transitions and state-change animations.

#### Section F: Data Requirements
For each displayed piece of information, identify source system, read/write, and update frequency.

#### Section G: Accessibility
Walk through the accessibility checklist for this screen.

#### Section H: Localization Considerations
Flag elements where 40% text expansion would break layout.

#### Section I: Acceptance Criteria
Write at least 5 testable criteria. Minimum: 1 performance, 1 navigation, 1 error state, 1 accessibility, 1 screen-specific.

### Section Guidance: HUD Design Mode

#### Section A: HUD Philosophy
Ask the user to describe the game's relationship with on-screen information.

#### Section B: Information Architecture
Pull all information from GDD UI Requirements. Categorize as Must Show / Contextual / On Demand / Hidden.

#### Section C: Layout Zones
Design zones after information architecture is approved.

#### Section D: HUD Elements
Specify each element: name, category, content, visual form, update behavior, trigger, animation.

### Section Guidance: Interaction Pattern Library Mode

#### Phase 1: Catalog Existing Patterns
Extract patterns from existing UX specs.

#### Phase 2: Formalize Each Pattern
Document: category, used in, description, specification, when to use, when NOT to use.

#### Phase 3: Identify Gaps
Ask about planned screens needing patterns not yet cataloged.

---

## 5. Cross-Reference Check

Before marking the spec as ready:

1. **GDD requirement coverage**: Does every GDD UI Requirement have a corresponding element?
2. **Pattern library alignment**: Are all patterns referenced by name?
3. **Navigation consistency**: Do entry/exit points match related specs?
4. **Accessibility coverage**: Does the spec address the committed tier?
5. **Empty states**: Does every data-dependent element have an empty state?

---

## 6. Handoff

When all sections are approved:

### 6a: Suggest Next Step

Use `vscode_askQuestions`:
- "Run `/cc-ux-review [filename]` now, or do something else first?"
  - Options:
    - "Run `/cc-ux-review` now — validate this spec"
    - "Design another screen first, then review all specs together"
    - "Update the interaction pattern library with new patterns from this spec"
    - "Stop here for this session"

---

## 7. Specialist Agent Routing

This skill uses `cc-ux-designer` as the primary agent. For specific sub-topics, use `runSubagent`:

| Topic | Coordinate with |
|-------|----------------|
| Visual aesthetics, color, layout feel | `cc-art-director` |
| Implementation feasibility | `cc-ui-programmer` |
| Gameplay data requirements | `cc-game-designer` |
| Narrative/lore visible in the UI | `cc-narrative-director` |

Agents do NOT write to files directly — this session owns all file writes.

---

## Collaborative Protocol

1. **Question -> Options -> Decision -> Draft -> Approval** for every section
2. **`vscode_askQuestions`** at every decision point
3. **"May I write to [filepath]?"** before the skeleton and before each section write
