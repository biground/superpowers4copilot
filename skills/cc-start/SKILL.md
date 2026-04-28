---
name: cc-start
description: "First-time onboarding — asks where you are, then guides you to the right workflow. No assumptions."
---

# Guided Onboarding

This skill writes one file: `production/review-mode.txt` (review mode config set in Phase 3b).

This skill is the entry point for new users. It does NOT assume you have a game idea, an engine preference, or any prior experience. It asks first, then routes you to the right workflow.

---

## Phase 1: Detect Project State

Before asking anything, silently gather context so you can tailor your guidance. Do NOT show these results unprompted — they inform your recommendations, not the conversation opener.

Check using `file_search` and `read_file`:
- **Engine configured?** Use `file_search` to look for a technical preferences file (e.g., `**/technical-preferences.md`). If found, use `read_file` to check if the Engine field contains `[TO BE CONFIGURED]` — if so, the engine is not set.
- **Game concept exists?** Use `file_search` for `**/game-concept.md`.
- **Source code exists?** Use `file_search` for source files in `src/` (`*.gd`, `*.cs`, `*.cpp`, `*.h`, `*.rs`, `*.py`, `*.js`, `*.ts`).
- **Prototypes exist?** Use `list_dir` to check for subdirectories in `prototypes/`.
- **Design docs exist?** Use `file_search` to count markdown files matching `design/gdd/*.md`.
- **Production artifacts?** Use `file_search` to check for files matching `production/sprints/*.md` or `production/milestones/*.md`.

Store these findings internally to validate the user's self-assessment and tailor recommendations.

---

## Phase 2: Ask Where the User Is

This is the first thing the user sees. Use `vscode_askQuestions` with these exact options so the user can click rather than type:

- **Prompt**: "Welcome to Claude Code Game Studios! Before I suggest anything, I'd like to understand where you're starting from. Where are you at with your game idea right now?"
- **Options**:
  - `A) No idea yet` — I don't have a game concept at all. I want to explore and figure out what to make.
  - `B) Vague idea` — I have a rough theme, feeling, or genre in mind (e.g., "something with space" or "a cozy farming game") but nothing concrete.
  - `C) Clear concept` — I know the core idea — genre, basic mechanics, maybe a pitch sentence — but haven't formalized it into documents yet.
  - `D) Existing work` — I already have design docs, prototypes, code, or significant planning done. I want to organize or continue the work.

Wait for the user's selection. Do not proceed until they respond.

---

## Phase 3: Route Based on Answer

#### If A: No idea yet

The user needs creative exploration before anything else.

1. Acknowledge that starting from zero is completely fine
2. Briefly explain what `/cc-brainstorm` does (guided ideation using professional frameworks — MDA, player psychology, verb-first design). Mention that it has two modes: `/cc-brainstorm open` for fully open exploration, or `/cc-brainstorm [hint]` if they have even a vague theme (e.g., "space", "cozy", "horror").
3. Recommend running `/cc-brainstorm open` as the next step, but invite them to use a hint if something comes to mind
4. Show the recommended path:
   **Concept phase:**
   - `/cc-brainstorm open` — discover your game concept
   - `/cc-setup-engine` — configure the engine (brainstorm will recommend one)
   - `/cc-art-bible` — define visual identity (uses the Visual Identity Anchor brainstorm produces)
   - `/cc-map-systems` — decompose the concept into systems
   - `/cc-design-system` — author a GDD for each MVP system
   - `/cc-review-all-gdds` — cross-system consistency check
   - `/cc-gate-check` — validate readiness before architecture work
   **Architecture phase:**
   - `/cc-create-architecture` — produce the master architecture blueprint and Required ADR list
   - `/cc-architecture-decision (×N)` — record key technical decisions, following the Required ADR list
   - `/cc-create-control-manifest` — compile decisions into an actionable rules sheet
   - `/cc-architecture-review` — validate architecture coverage
   **Pre-Production phase:**
   - `/cc-ux-design` — author UX specs for key screens (main menu, HUD, core interactions)
   - `/cc-prototype` — build a throwaway prototype to validate the core mechanic
   - `/cc-playtest-report (×1+)` — document each vertical slice playtest session
   - `/cc-create-epics` — map systems to epics
   - `/cc-create-stories` — break epics into implementable stories
   - `/cc-sprint-plan` — plan the first sprint
   **Production phase:** → pick up stories with `/cc-dev-story`

#### If B: Vague idea

1. Ask them to share their vague idea — even a few words is enough
2. Validate the idea as a starting point (don't judge or redirect)
3. Recommend running `/cc-brainstorm [their hint]` to develop it
4. Show the recommended path:
   **Concept phase:**
   - `/cc-brainstorm [hint]` — develop the idea into a full concept
   - `/cc-setup-engine` — configure the engine
   - `/cc-art-bible` — define visual identity (uses the Visual Identity Anchor brainstorm produces)
   - `/cc-map-systems` — decompose the concept into systems
   - `/cc-design-system` — author a GDD for each MVP system
   - `/cc-review-all-gdds` — cross-system consistency check
   - `/cc-gate-check` — validate readiness before architecture work
   **Architecture phase:**
   - `/cc-create-architecture` — produce the master architecture blueprint and Required ADR list
   - `/cc-architecture-decision (×N)` — record key technical decisions, following the Required ADR list
   - `/cc-create-control-manifest` — compile decisions into an actionable rules sheet
   - `/cc-architecture-review` — validate architecture coverage
   **Pre-Production phase:**
   - `/cc-ux-design` — author UX specs for key screens (main menu, HUD, core interactions)
   - `/cc-prototype` — build a throwaway prototype to validate the core mechanic
   - `/cc-playtest-report (×1+)` — document each vertical slice playtest session
   - `/cc-create-epics` — map systems to epics
   - `/cc-create-stories` — break epics into implementable stories
   - `/cc-sprint-plan` — plan the first sprint
   **Production phase:** → pick up stories with `/cc-dev-story`

#### If C: Clear concept

1. Ask them to describe their concept in one sentence — genre and core mechanic. Use plain text, not `vscode_askQuestions` (it's an open response).
2. Acknowledge the concept, then use `vscode_askQuestions` to offer two paths:
   - **Prompt**: "How would you like to proceed?"
   - **Options**:
     - `Formalize it first` — Run `/cc-brainstorm [concept]` to structure it into a proper game concept document
     - `Jump straight in` — Go to `/cc-setup-engine` now and write the GDD manually afterward
3. Show the recommended path:
   **Concept phase:**
   - `/cc-brainstorm` or `/cc-setup-engine` — (their pick from step 2)
   - `/cc-art-bible` — define visual identity (after brainstorm if run, or after concept doc exists)
   - `/cc-design-review` — validate the concept doc
   - `/cc-map-systems` — decompose the concept into individual systems
   - `/cc-design-system` — author a GDD for each MVP system
   - `/cc-review-all-gdds` — cross-system consistency check
   - `/cc-gate-check` — validate readiness before architecture work
   **Architecture phase:**
   - `/cc-create-architecture` — produce the master architecture blueprint and Required ADR list
   - `/cc-architecture-decision (×N)` — record key technical decisions, following the Required ADR list
   - `/cc-create-control-manifest` — compile decisions into an actionable rules sheet
   - `/cc-architecture-review` — validate architecture coverage
   **Pre-Production phase:**
   - `/cc-ux-design` — author UX specs for key screens (main menu, HUD, core interactions)
   - `/cc-prototype` — build a throwaway prototype to validate the core mechanic
   - `/cc-playtest-report (×1+)` — document each vertical slice playtest session
   - `/cc-create-epics` — map systems to epics
   - `/cc-create-stories` — break epics into implementable stories
   - `/cc-sprint-plan` — plan the first sprint
   **Production phase:** → pick up stories with `/cc-dev-story`

#### If D: Existing work

1. Share what you found in Phase 1:
   - "I can see you have [X source files / Y design docs / Z prototypes]..."
   - "Your engine is [configured as X / not yet configured]..."

2. **Sub-case D1 — Early stage** (engine not configured or only a game concept exists):
   - Recommend `/cc-setup-engine` first if engine not configured
   - Then `/cc-project-stage-detect` for a gap inventory

   **Sub-case D2 — GDDs, ADRs, or stories already exist:**
   - Explain: "Having files isn't the same as the template's skills being able to use them. GDDs might be missing required sections. `/cc-adopt` checks this specifically."
   - Recommend:
     1. `/cc-project-stage-detect` — understand what phase and what's missing entirely
     2. `/cc-adopt` — audit whether existing artifacts are in the right internal format

3. Show the recommended path for D2:
   - `/cc-project-stage-detect` — phase detection + existence gaps
   - `/cc-adopt` — format compliance audit + migration plan
   - `/cc-setup-engine` — if engine not configured
   - `/cc-design-system retrofit [path]` — fill missing GDD sections
   - `/cc-architecture-decision retrofit [path]` — add missing ADR sections
   - `/cc-architecture-review` — bootstrap the TR requirement registry
   - `/cc-gate-check` — validate readiness for next phase

---

## Phase 3b: Set Review Mode

Check if `production/review-mode.txt` already exists using `file_search`.

**If it exists**: Use `read_file` to read it and show the current mode — "Review mode is set to `[current]`." — then proceed to Phase 4. Do not ask again.

**If it does not exist**: Use `vscode_askQuestions`:

- **Prompt**: "One setup choice: how much design review would you want as you work through the workflow?"
- **Options**:
  - `Full` — Director specialists review at each key workflow step. Best for teams, learning the workflow, or when you want thorough feedback on every decision.
  - `Lean (recommended)` — Directors only at phase gate transitions (/cc-gate-check). Skips per-skill reviews. Balanced approach for solo devs and small teams.
  - `Solo` — No director reviews at all. Maximum speed. Best for game jams, prototypes, or if the reviews feel like overhead.

Write the choice to `production/review-mode.txt` immediately after the user selects using `create_file` — no separate "May I write?" needed, as the write is a direct consequence of the selection:
- `Full` → write `full`
- `Lean (recommended)` → write `lean`
- `Solo` → write `solo`

Create the `production/` directory if it does not exist.

---

## Phase 4: Confirm Before Proceeding

After presenting the recommended path, use `vscode_askQuestions` to ask the user which step they'd like to take first. Never auto-run the next skill.

- **Prompt**: "Would you like to start with [recommended first step]?"
- **Options**:
  - `Yes, let's start with [recommended first step]`
  - `I'd like to do something else first`

If the user picks the recommended step, use `read_file` to load the corresponding SKILL.md and follow its instructions.
