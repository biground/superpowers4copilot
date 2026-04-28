---
name: cc-team-level
description: "Orchestrate level design team: cc-level-designer + cc-narrative-director + cc-world-builder + cc-art-director + cc-systems-designer + cc-qa-tester for complete area/level creation."
---

When this skill is invoked:

**Decision Points:** At each step transition, use `vscode_askQuestions` to present
the user with the subagent's proposals as selectable options. Write the agent's
full analysis in conversation, then capture the decision with concise labels.
The user must approve before moving to the next step.

1. **Read the argument** for the target level or area (e.g., `tutorial`,
   `forest dungeon`, `hub town`, `final boss arena`).

2. **Gather context**:
   - Use `read_file` to read the game concept at `design/gdd/game-concept.md`
   - Use `read_file` to read game pillars at `design/gdd/game-pillars.md`
   - Use `file_search` and `read_file` to read existing level docs in `design/levels/`
   - Use `read_file` to read relevant narrative docs in `design/narrative/`
   - Read world-building docs for the area's region/faction

## How to Delegate

Use `runSubagent` to spawn each team member as a subagent:
- `cc-narrative-director` — Narrative purpose, characters, emotional arc
- `cc-world-builder` — Lore context, environmental storytelling, world rules
- `cc-level-designer` — Spatial layout, pacing, encounters, navigation
- `cc-systems-designer` — Enemy compositions, loot tables, difficulty balance
- `cc-art-director` — Visual theme, color palette, lighting, asset requirements
- `cc-accessibility-specialist` — Navigation clarity, colorblind safety, cognitive load
- `cc-qa-tester` — Test cases, boundary testing, playtest checklist

Always provide full context in each agent's prompt (game concept, pillars, existing level docs, narrative docs).

3. **Orchestrate the level design team** in sequence:

### Step 1: Narrative + Visual Direction (parallel)

Spawn all three agents simultaneously via `runSubagent` — issue all three calls before waiting for any result.

Spawn `cc-narrative-director` to:
- Define the narrative purpose of this area (what story beats happen here?)
- Identify key characters, dialogue triggers, and lore elements
- Specify emotional arc (how should the player feel entering, during, leaving?)

Spawn `cc-world-builder` to:
- Provide lore context for the area (history, faction presence, ecology)
- Define environmental storytelling opportunities
- Specify any world rules that affect gameplay in this area

Spawn `cc-art-director` to:
- Establish visual theme targets for this area — these are INPUTS to layout, not outputs of it
- Define the color temperature and lighting mood for this area (how does it differ from adjacent areas?)
- Specify shape language direction (angular fortress? organic cave? decayed grandeur?)
- Name the primary visual landmarks that will orient the player
- Read `design/art/art-bible.md` if it exists — anchor all direction in the established art bible

**The cc-art-director's visual targets from Step 1 must be passed to the cc-level-designer in Step 2** as explicit constraints. Layout decisions happen within the visual direction, not before it.

**Gate**: Use `vscode_askQuestions` to present all three Step 1 outputs (narrative brief, lore foundation, visual direction targets) and confirm before proceeding to Step 2.

### Step 2: Layout and Encounter Design (cc-level-designer)
Spawn `cc-level-designer` via `runSubagent` with the full Step 1 output as context:
- Narrative brief (from cc-narrative-director)
- Lore foundation (from cc-world-builder)
- **Visual direction targets (from cc-art-director)** — layout must work within these targets, not contradict them

The cc-level-designer should:
- Design the spatial layout (critical path, optional paths, secrets) — ensuring primary routes align with the visual landmark targets from Step 1
- Define pacing curve (tension peaks, rest areas, exploration zones) — coordinated with the emotional arc from cc-narrative-director
- Place encounters with difficulty progression
- Design environmental puzzles or navigation challenges
- Define points of interest and landmarks for wayfinding — these must match the visual landmarks the cc-art-director specified
- Specify entry/exit points and connections to adjacent areas

**Adjacent area dependency check**: After the layout is produced, use `file_search` to check `design/levels/` for each adjacent area referenced by the cc-level-designer. If any referenced area's `.md` file does not exist, surface the gap:
> "Level references [area-name] as an adjacent area but `design/levels/[area-name].md` does not exist."

Use `vscode_askQuestions` with options:
- (a) Proceed with a placeholder reference — mark the connection as UNRESOLVED in the level doc and list it in the open cross-level dependencies section of the summary report
- (b) Pause and run `/cc-team-level [area-name]` first to establish that area

Do NOT invent content for the missing adjacent area.

**Gate**: Use `vscode_askQuestions` to present Step 2 layout (including any unresolved adjacent area dependencies) and confirm before proceeding to Step 3.

### Step 3: Systems Integration (cc-systems-designer)
Spawn `cc-systems-designer` via `runSubagent` to:
- Specify enemy compositions and encounter formulas
- Define loot tables and reward placement
- Balance difficulty relative to expected player level/gear
- Design any area-specific mechanics or environmental hazards
- Specify resource distribution (health pickups, save points, shops)

**Gate**: Use `vscode_askQuestions` to present Step 3 outputs and confirm before proceeding to Step 4.

### Step 4: Production Concepts + Accessibility (parallel)

**Note**: The cc-art-director's directional pass (visual theme, color targets, mood) happened in Step 1. This pass is location-specific production concepts — given the finalized layout, what does each specific space look like?

Spawn `cc-art-director` via `runSubagent` with the finalized layout from Step 2:
- Produce location-specific concept specs for key spaces (entrance, key encounter zones, landmarks, exits)
- Specify which art assets are unique to this area vs. shared from the global pool
- Define sight-line and lighting setups per key space (these are now layout-informed, not directional)
- Specify VFX needs that are specific to this area's layout (weather volumes, particles, atmospheric effects)
- Flag any locations where the layout creates visual direction conflicts with the Step 1 targets — surface these as production risks

Spawn `cc-accessibility-specialist` via `runSubagent` in parallel to:
- Review the level layout for navigation clarity (can players orient themselves without relying on color alone?)
- Check that critical path signposting uses shape/icon/sound cues in addition to color
- Review any puzzle mechanics for cognitive load — flag anything that requires holding more than 3 simultaneous states
- Check that key gameplay areas have sufficient contrast for colorblind players
- Output: accessibility concerns list with severity (BLOCKING / RECOMMENDED / NICE TO HAVE)

Wait for both agents to return before proceeding.

**Gate**: Use `vscode_askQuestions` to present both Step 4 results. If the cc-accessibility-specialist returned any BLOCKING concerns, highlight them prominently and offer:
- (a) Return to cc-level-designer and cc-art-director to redesign the flagged elements before Step 5
- (b) Document as a known accessibility gap and proceed to Step 5 with the concern explicitly logged in the final report

Do NOT proceed to Step 5 without the user acknowledging any BLOCKING accessibility concerns.

### Step 5: QA Planning (cc-qa-tester)
Spawn `cc-qa-tester` via `runSubagent` to:
- Write test cases for the critical path
- Identify boundary and edge cases (sequence breaks, softlocks)
- Create a playtest checklist for the area
- Define acceptance criteria for level completion

4. **Compile the level design document** combining all team outputs into the
   level design template format.

5. **Save to** `design/levels/[level-name].md`.

6. **Output a summary** with: area overview, encounter count, estimated asset
   list, narrative beats, any cross-team dependencies or open questions, open
   cross-level dependencies (adjacent areas referenced but not yet designed, each
   marked UNRESOLVED), and accessibility concerns with their resolution status.

## File Write Protocol

All file writes (level design docs, narrative docs, test checklists) are delegated
to sub-agents spawned via `runSubagent`. Each sub-agent enforces the "May I write to [path]?"
protocol. This orchestrator does not write files directly.

Verdict: **COMPLETE** — level design document produced and all team outputs compiled.
Verdict: **BLOCKED** — one or more agents blocked; partial report produced with unresolved items listed.

## Next Steps

- Run `/cc-design-review design/levels/[level-name].md` to validate the completed level design doc.
- Run `/cc-dev-story` to implement level content once the design is approved.
- Run `/cc-qa-plan` to generate a QA test plan for this level.

## Error Recovery Protocol

If any spawned agent (via `runSubagent`) returns BLOCKED, errors, or cannot complete:

1. **Surface immediately**: Report "[AgentName]: BLOCKED — [reason]" to the user before continuing to dependent phases
2. **Assess dependencies**: Check whether the blocked agent's output is required by subsequent phases. If yes, do not proceed past that dependency point without user input.
3. **Offer options** via `vscode_askQuestions` with choices:
   - Skip this agent and note the gap in the final report
   - Retry with narrower scope
   - Stop here and resolve the blocker first
4. **Always produce a partial report** — output whatever was completed. Never discard work because one agent blocked.

Common blockers:
- Input file missing (story not found, GDD absent) → redirect to the skill that creates it
- ADR status is Proposed → do not implement; run `/cc-architecture-decision` first
- Scope too large → split into two stories via `/cc-create-stories`
- Conflicting instructions between ADR and story → surface the conflict, do not guess
