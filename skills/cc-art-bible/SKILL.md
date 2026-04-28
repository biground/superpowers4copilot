---
name: cc-art-bible
description: "Guided, section-by-section Art Bible authoring. Creates the visual identity specification that gates all asset production. Run after /cc-brainstorm is approved and before /cc-map-systems or any GDD authoring begins."
---

## Phase 0: Parse Arguments and Context Check

Resolve the review mode (once, store for all gate spawns this run):
1. If `--review [full|lean|solo]` was passed → use that
2. Else use `file_search` to find `**/review-mode.txt`, then `read_file` → use that value
3. Else → default to `lean`

Use `read_file` on `design/gdd/game-concept.md`. If it does not exist, fail with:
> "No game concept found. Run `/cc-brainstorm` first — the art bible is authored after the game concept is approved."

Extract from game-concept.md:
- Game title (working title)
- Core fantasy and elevator pitch
- Game pillars (all of them)
- **Visual Identity Anchor** section if present (from brainstorm Phase 4 art-director output)
- Target platform (if noted)

**Retrofit mode detection**: Use `file_search` for `design/art/art-bible.md`. If the file exists:
- Read it in full
- For each of the 9 sections, check whether the body contains real content vs. placeholder
- Build a section status table and present it
- Only work on sections with Status: Empty or Placeholder

Read the project technical preferences file if it exists — extract performance budgets and engine for asset standard constraints.

---

## Phase 1: Framing

Present the session context and ask two questions before authoring anything:

Use `vscode_askQuestions` with two questions:
- **"Scope"** — "Which sections need to be authored today?"
  Options: `Full bible — all 9 sections` / `Visual identity core (sections 1–4 only)` / `Asset standards only (section 8)` / `Resume — fill in missing sections`
- **"References"** — "Do you have reference games, films, or art that define the visual direction?"
  (Free text — let the user type specific titles.)

If the game-concept.md has a Visual Identity Anchor section, note it:
> "Found a visual identity anchor from brainstorm: '[anchor name] — [one-line rule]'. I'll use this as the foundation."

---

## Phase 2: Visual Identity Foundation (Sections 1–4)

These four sections define the core visual language. **All other sections flow from them.** Author and write each to file before moving to the next.

### Section 1: Visual Identity Statement

**Goal**: A one-line visual rule plus 2–3 supporting principles that resolve visual ambiguity.

**Agent delegation (MANDATORY)**: Spawn `cc-art-director` via `runSubagent`:
- Provide: game concept (elevator pitch, core fantasy), full pillar set, platform target, any references, the visual anchor if it exists
- Ask: "Draft a Visual Identity Statement. Provide: (1) a one-line visual rule, (2) 2–3 supporting visual principles, each with a design test."

Present the draft. Use `vscode_askQuestions`:
- Options: `[A] Lock this in` / `[B] Revise the one-liner` / `[C] Revise a supporting principle` / `[D] Describe my own direction`

Write the approved section to file immediately using `create_file` or `replace_string_in_file`.

### Section 2: Mood & Atmosphere

**Agent delegation**: Spawn `cc-art-director` via `runSubagent` with the Visual Identity Statement and pillar set. Ask: "Define mood and atmosphere targets for each major game state. Be specific — name the exact emotional target, lighting character, and at least one visual element that carries the mood."

Write the approved section to file immediately.

### Section 3: Shape Language

**Agent delegation**: Spawn `cc-art-director` via `runSubagent` with Visual Identity Statement and mood targets. Ask: "Define the shape language. Connect each shape principle back to the visual identity statement and a specific pillar."

Write the approved section to file immediately.

### Section 4: Color System

**Agent delegation**: Spawn `cc-art-director` via `runSubagent` with Visual Identity Statement and mood targets. Ask: "Design the color system. Every semantic color assignment must be explained. Identify which color pairs might fail colorblind players and specify backup cues."

Write the approved section to file immediately.

---

## Phase 3: Production Guides (Sections 5–8)

These sections translate the visual identity into concrete production rules.

### Section 5: Character Design Direction

**Agent delegation**: Spawn `cc-art-director` via `runSubagent` with sections 1–4.

Write the approved section to file.

### Section 6: Environment Design Language

**Agent delegation**: Spawn `cc-art-director` via `runSubagent` with sections 1–4.

Write the approved section to file.

### Section 7: UI/HUD Visual Direction

**Agent delegation**: Spawn in parallel via `runSubagent`:
- **`cc-art-director`**: Visual style for UI
- **`cc-ux-designer`** (if available): UX alignment check

If they conflict, surface the conflict explicitly with both positions. Use `vscode_askQuestions` to let the user decide.

Write the approved section to file.

### Section 8: Asset Standards

**Agent delegation**: Spawn in parallel via `runSubagent`:
- **`cc-art-director`**: File format preferences, naming conventions, texture resolution tiers
- **`cc-technical-artist`**: Engine-specific hard constraints — poly count budgets, texture memory limits, material slot counts

If any preference conflicts with a technical constraint, resolve explicitly — note both the ideal and the constrained standard.

Write the approved section to file.

---

## Phase 4: Reference Direction (Section 9)

**Agent delegation**: Spawn `cc-art-director` via `runSubagent` with completed sections 1–8. Ask: "Compile a reference direction. 3–5 reference sources. For each: name it, specify exactly what visual element to draw from it, and what to explicitly avoid."

Write the approved section to file.

---

## Phase 5: Art Director Sign-Off

**Review mode check** — apply before spawning AD-ART-BIBLE:
- `solo` → skip. Proceed to Phase 6.
- `lean` → skip. Proceed to Phase 6.
- `full` → spawn as normal.

Spawn `cc-creative-director` via `runSubagent` with: art bible file path, game pillars, visual identity anchor.

Record the verdict in the art bible's status header:
`> **Art Director Sign-Off (AD-ART-BIBLE)**: APPROVED [date] / CONCERNS (accepted) [date] / REVISED [date]`

---

## Phase 6: Close

After all sections are complete:

Use `vscode_askQuestions`:
- Prompt: "Art Bible complete. What's next?"
- Options:
  - `[A] Map systems — run /cc-map-systems`
  - `[B] Start first GDD — run /cc-design-system [system]`
  - `[C] Stop here for this session`
