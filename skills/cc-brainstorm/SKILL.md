---
name: cc-brainstorm
description: "Guided game concept ideation — from zero idea to a structured game concept document. Uses professional studio ideation techniques, player psychology frameworks, and structured creative exploration."
---

When this skill is invoked:

1. **Parse the argument** for an optional genre/theme hint (e.g., `roguelike`,
   `space survival`, `cozy farming`). If `open` or no argument, start from
   scratch. Also resolve the review mode (once, store for all gate spawns this run):
   1. If `--review [full|lean|solo]` was passed → use that
   2. Else use `file_search` to find `**/review-mode.txt`, then `read_file` → use that value
   3. Else → default to `lean`

2. **Check for existing concept work**:
   - Use `read_file` to read `design/gdd/game-concept.md` if it exists (resume, don't restart)
   - Use `read_file` to read `design/gdd/game-pillars.md` if it exists (build on established pillars)

3. **Run through ideation phases** interactively, asking the user questions at
   each phase. Do NOT generate everything silently — the goal is **collaborative
   exploration** where the AI acts as a creative facilitator, not a replacement
   for the human's vision.

   **Use `vscode_askQuestions`** at key decision points throughout brainstorming:
   - Constrained taste questions (genre preferences, scope, team size)
   - Concept selection ("Which 2-3 concepts resonate?") after presenting options
   - Direction choices ("Develop further, explore more, or prototype?")
   - Pillar ranking after concepts are refined
   Write full creative analysis in conversation text first, then use
   `vscode_askQuestions` to capture the decision with concise labels.

   Professional studio brainstorming principles to follow:
   - Withhold judgment — no idea is bad during exploration
   - Encourage unusual ideas — outside-the-box thinking sparks better concepts
   - Build on each other — "yes, and..." responses, not "but..."
   - Use constraints as creative fuel — limitations often produce the best ideas
   - Time-box each phase — keep momentum, don't over-deliberate early

---

### Phase 1: Creative Discovery

Start by understanding the person, not the game. Ask these questions
conversationally (not as a checklist):

**Emotional anchors**:
- What's a moment in a game that genuinely moved you, thrilled you, or made
  you lose track of time? What specifically created that feeling?
- Is there a fantasy or power trip you've always wanted in a game but never
  quite found?

**Taste profile**:
- What 3 games have you spent the most time with? What kept you coming back?
  *(Ask this as plain text — the user must be able to type specific game names freely.
  Do NOT put this in a `vscode_askQuestions` with preset options.)*
- Are there genres you love? Genres you avoid? Why?
- Do you prefer games that challenge you, relax you, tell you stories,
  or let you express yourself? *(Use `vscode_askQuestions` for this — constrained choice.)*

**Practical constraints** (shape the sandbox before brainstorming).
Bundle these into a single `vscode_askQuestions` call with multiple questions:
- Question "Experience" — "What kind of experience do you most want players to have?" (Challenge & Mastery / Story & Discovery / Expression & Creativity / Relaxation & Flow)
- Question "Timeline" — "What's your realistic development timeline?" (Weeks / Months / 1-2 years / Multi-year)
- Question "Dev level" — "Where are you in your dev journey?" (First game / Shipped before / Professional background)

**Synthesize** the answers into a **Creative Brief** — a 3-5 sentence
summary of the person's emotional goals, taste profile, and constraints.
Read the brief back and confirm it captures their intent.

---

### Phase 2: Concept Generation

Using the creative brief as a foundation, generate **3 distinct concepts**
that each take a different creative direction. Use these ideation techniques:

**Technique 1: Verb-First Design**
Start with the core player verb (build, fight, explore, solve, survive,
create, manage, discover) and build outward from there. The verb IS the game.

**Technique 2: Mashup Method**
Combine two unexpected elements: [Genre A] + [Theme B]. The tension between
the two creates the unique hook. (e.g., "farming sim + cosmic horror",
"roguelike + dating sim", "city builder + real-time combat")

**Technique 3: Experience-First Design (MDA Backward)**
Start from the desired player emotion (aesthetic goal from MDA framework:
sensation, fantasy, narrative, challenge, fellowship, discovery, expression,
submission) and work backward to the dynamics and mechanics that produce it.

For each concept, present:
- **Working Title**
- **Elevator Pitch** (1-2 sentences — must pass the "10-second test")
- **Core Verb** (the single most common player action)
- **Core Fantasy** (the emotional promise)
- **Unique Hook** (passes the "and also" test: "Like X, AND ALSO Y")
- **Primary MDA Aesthetic** (which emotion dominates?)
- **Estimated Scope** (small / medium / large)
- **Why It Could Work** (1 sentence on market/audience fit)
- **Biggest Risk** (1 sentence on the hardest unanswered question)

Present all three. Then use `vscode_askQuestions` to capture the selection:

```
vscode_askQuestions(
  prompt: "Which concept resonates with you? You can pick one, combine elements, or ask for fresh directions.",
  options: [
    "Concept 1 — [Title]",
    "Concept 2 — [Title]",
    "Concept 3 — [Title]",
    "Combine elements across concepts",
    "Generate fresh directions"
  ]
)
```

Never pressure toward a choice — let them sit with it.

---

### Phase 3: Core Loop Design

For the chosen concept, use structured questioning to build the core loop.
The core loop is the beating heart of the game — if it isn't fun in
isolation, no amount of content or polish will save the game.

**30-Second Loop** (moment-to-moment):

Ask these as `vscode_askQuestions` calls — derive the options from the chosen concept, don't hardcode them:

1. **Core action feel** — prompt: "What's the primary feel of the core action?" Generate 3-4 options that fit the concept's genre and tone, plus a free-text escape (`I'll describe it`).

2. **Key design dimension** — identify the most important design variable for this specific concept (e.g., world reactivity, pacing, player agency) and ask about it. Generate options that match the concept. Always include a free-text escape.

After capturing answers, analyze: Is this action intrinsically satisfying? What makes it feel good? (Audio feedback, visual juice, timing satisfaction, tactical depth?)

**5-Minute Loop** (short-term goals):
- What structures the moment-to-moment play into cycles?
- Where does "one more turn" / "one more run" psychology kick in?
- What choices does the player make at this level?

**Session Loop** (30-120 minutes):
- What does a complete session look like?
- Where are the natural stopping points?
- What's the "hook" that makes them think about the game when not playing?

**Progression Loop** (days/weeks):
- How does the player grow? (Power? Knowledge? Options? Story?)
- What's the long-term goal? When is the game "done"?

**Player Motivation Analysis** (based on Self-Determination Theory):
- **Autonomy**: How much meaningful choice does the player have?
- **Competence**: How does the player feel their skill growing?
- **Relatedness**: How does the player feel connected (to characters,
  other players, or the world)?

---

### Phase 4: Pillars and Boundaries

Game pillars are used by real AAA studios (God of War, Hades, The Last of
Us) to keep hundreds of team members making decisions that all point the
same direction. Even for solo developers, pillars prevent scope creep and
keep the vision sharp.

Collaboratively define **3-5 pillars**:
- Each pillar has a **name** and **one-sentence definition**
- Each pillar has a **design test**: "If we're debating between X and Y,
  this pillar says we choose __"
- Pillars should feel like they create tension with each other — if all
  pillars point the same way, they're not doing enough work

Then define **3+ anti-pillars** (what this game is NOT):
- Anti-pillars prevent the most common form of scope creep: "wouldn't it
  be cool if..." features that don't serve the core vision
- Frame as: "We will NOT do [thing] because it would compromise [pillar]"

**Pillar confirmation**: After presenting the full pillar set, use `vscode_askQuestions`:
- Prompt: "Do these pillars feel right for your game?"
- Options: `[A] Lock these in` / `[B] Rename or reframe one` / `[C] Swap a pillar out` / `[D] Something else`

If the user selects B, C, or D, make the revision, then use `vscode_askQuestions` again:
- Prompt: "Pillars updated. Ready to lock these in?"
- Options: `[A] Lock these in` / `[B] Revise another pillar` / `[C] Something else`

Repeat until the user selects [A] Lock these in.

**Review mode check** — apply before spawning director reviews:
- `solo` → skip director reviews. Note: "Director reviews skipped — Solo mode." Proceed to Phase 5.
- `lean` → skip director reviews (not phase gates). Note: "Director reviews skipped — Lean mode." Proceed to Phase 5.
- `full` → spawn `cc-creative-director` and `cc-art-director` via `runSubagent` in parallel.

**If full mode**: After pillars and anti-pillars are agreed, dispatch BOTH `cc-creative-director` AND `cc-art-director` via `runSubagent` in parallel.

- **`cc-creative-director`** — gate **CD-PILLARS**: Pass full pillar set with design tests, anti-pillars, core fantasy, unique hook.
- **`cc-art-director`** — gate **AD-CONCEPT-VISUAL**: Pass game concept elevator pitch, full pillar set with design tests, target platform (if known), any reference games or visual touchstones the user mentioned.

Collect both verdicts, then present them together using `vscode_askQuestions` with two questions:
- Question **"Pillars"**: present cc-creative-director feedback. Options: `Lock in as-is` / `Revise [specific pillar]` / `Discuss further`.
- Question **"Visual anchor"**: present the cc-art-director's 2-3 named visual direction options. Options: each named direction (one per option) + `Combine elements across directions` + `Describe my own direction`.

The user's selected visual anchor is stored as the **Visual Identity Anchor** — it will be written into the game-concept document and becomes the foundation of the art bible.

If the cc-creative-director returns CONCERNS or REJECT on pillars, resolve pillar issues before asking for the visual anchor selection.

---

### Phase 5: Player Type Validation

Using the Bartle taxonomy and Quantic Foundry motivation model, validate
who this game is actually for:

- **Primary player type**: Who will LOVE this game? (Achievers, Explorers,
  Socializers, Competitors, Creators, Storytellers)
- **Secondary appeal**: Who else might enjoy it?
- **Who is this NOT for**: Being clear about who won't like this game is as
  important as knowing who will
- **Market validation**: Are there successful games that serve a similar
  player type? What can we learn from their audience size?

---

### Phase 6: Scope and Feasibility

Ground the concept in reality:

- **Target platform**: Use `vscode_askQuestions` — "What platforms are you targeting for this game?"
  Options: `PC (Steam / Epic)` / `Mobile (iOS / Android)` / `Console` / `Web / Browser` / `Multiple platforms`
  Record the answer — it directly shapes the engine recommendation and will be passed to `/cc-setup-engine`.

- **Engine experience**: Use `vscode_askQuestions` — "Do you already have an engine you work in?"
  Options: `Godot` / `Unity` / `Unreal Engine 5` / `No preference — help me decide`
  - If they pick an engine → record it as their preference and move on. Do NOT second-guess it.
  - If "No preference" → tell them: "Run `/cc-setup-engine` after this session — it will walk you through the full decision based on your concept and platform target." Do not make a recommendation here.
- **Art pipeline**: What's the art style and how labor-intensive is it?
- **Content scope**: Estimate level/area count, item count, gameplay hours
- **MVP definition**: What's the absolute minimum build that tests "is the
  core loop fun?"
- **Biggest risks**: Technical risks, design risks, market risks
- **Scope tiers**: What's the full vision vs. what ships if time runs out?

**Review mode check** — apply before spawning director reviews:
- `solo` → skip. Note: "TD-FEASIBILITY skipped — Solo mode." Proceed directly to scope tier definition.
- `lean` → skip (not a phase gate). Note: "TD-FEASIBILITY skipped — Lean mode." Proceed directly to scope tier definition.
- `full` → spawn `cc-technical-director` via `runSubagent` using gate TD-FEASIBILITY.

Pass: core loop description, platform target, engine choice (or "undecided"), list of identified technical risks.

Present the assessment to the user. If HIGH RISK, offer to revisit scope before finalising. If CONCERNS, note them and continue.

**After scope tiers are defined** (review mode check again):
- `solo` → skip. Note: "PR-SCOPE skipped — Solo mode." Proceed to document generation.
- `lean` → skip. Note: "PR-SCOPE skipped — Lean mode." Proceed to document generation.
- `full` → spawn `cc-producer` via `runSubagent` using gate PR-SCOPE.

Pass: full vision scope, MVP definition, timeline estimate, team size.

Present the assessment to the user. If UNREALISTIC, offer to adjust the MVP definition or scope tiers before writing the document.

---

4. **Generate the game concept document** using the template at
   `design/templates/game-concept.md` (or a built-in template if no template file exists).
   Fill in ALL sections from the brainstorm conversation, including the MDA analysis,
   player motivation profile, and flow state design sections.

   **Include a Visual Identity Anchor section** in the game concept document with:
   - The selected visual direction name
   - The one-line visual rule
   - The 2-3 supporting visual principles with their design tests
   - The color philosophy summary

   This section is the seed of the art bible — it captures the "everything must
   move" decision before it can be forgotten between sessions.

5. Use `vscode_askQuestions` for write approval:
- Prompt: "Game concept is ready. May I write it to `design/gdd/game-concept.md`?"
- Options: `[A] Yes — write it` / `[B] Not yet — revise a section first`

If [B]: ask which section to revise using `vscode_askQuestions` with options: `Elevator Pitch` / `Core Fantasy & Unique Hook` / `Pillars` / `Core Loop` / `MVP Definition` / `Scope Tiers` / `Risks` / `Something else — I'll describe`

After revising, show the updated section as a diff or clear before/after, then use `vscode_askQuestions` — "Ready to write the updated concept document?"
Options: `[A] Yes — write it` / `[B] Revise another section`
Repeat until the user selects [A].

If yes, generate the document and write the file using `create_file`, creating directories as needed.

**Scope consistency rule**: The "Estimated Scope" field in the Core Identity table must match the full-vision timeline from the Scope Tiers section — not just say "Large (9+ months)". Write it as "Large (X–Y months, solo)" or "Large (X–Y months, team of N)" so the summary table is accurate.

6. **Suggest next steps** (in this order — this is the professional studio
   pre-production pipeline). List ALL steps — do not abbreviate or truncate:
   1. "Run `/cc-setup-engine` to configure the engine and populate version-aware reference docs"
   2. "Run `/cc-art-bible` to create the visual identity specification — do this BEFORE writing GDDs. The art bible gates asset production and shapes technical architecture decisions (rendering, VFX, UI systems)."
   3. "Use `/cc-design-review design/gdd/game-concept.md` to validate concept completeness before going downstream"
   4. "Discuss vision with the `cc-creative-director` agent for pillar refinement"
   5. "Decompose the concept into individual systems with `/cc-map-systems` — maps dependencies, assigns priorities, and creates the systems index"
   6. "Author per-system GDDs with `/cc-design-system` — guided, section-by-section GDD writing for each system identified in step 5"
   7. "Plan the technical architecture with `/cc-create-architecture` — produces the master architecture blueprint and Required ADR list"
   8. "Record key architectural decisions with `/cc-architecture-decision (×N)` — write one ADR per decision in the Required ADR list from `/cc-create-architecture`"
   9. "Validate readiness to advance with `/cc-gate-check` — phase gate before committing to production"
   10. "Prototype the riskiest system with `/cc-prototype [core-mechanic]` — validate the core loop before full implementation"
   11. "Run `/cc-playtest-report` after the prototype to validate the core hypothesis"
   12. "If validated, plan the first sprint with `/cc-sprint-plan new`"

7. **Output a summary** with the chosen concept's elevator pitch, pillars,
   primary player type, engine recommendation, biggest risk, and file path.

Verdict: **COMPLETE** — game concept created and handed off for next steps.

---

## Context Window Awareness

This is a multi-phase skill. If context reaches or exceeds 70% during any phase,
append this notice to the current response before continuing:

> **Context is approaching the limit (≥70%).** The game concept document is saved
> to `design/gdd/game-concept.md`. Open a fresh session to continue if needed —
> progress is not lost.

---

## Recommended Next Steps

After the game concept is written, follow the pre-production pipeline in order:
1. `/cc-setup-engine` — configure the engine and populate version-aware reference docs
2. `/cc-art-bible` — establish visual identity before writing any GDDs
3. `/cc-map-systems` — decompose the concept into individual systems with dependencies
4. `/cc-design-system [first-system]` — author per-system GDDs in dependency order
5. `/cc-create-architecture` — produce the master architecture blueprint
6. `/cc-gate-check pre-production` — validate readiness before committing to production
