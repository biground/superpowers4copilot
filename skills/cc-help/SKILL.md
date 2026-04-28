---
name: cc-help
description: "Analyzes what is done and offers advice on what to do next. Use if user says what should I do next or what do I do now or I'm stuck or I don't know what to do"
---

# Studio Help — What Do I Do Next?

This skill is read-only — it reports findings but writes no files.

This skill figures out exactly where you are in the game development pipeline and
tells you what comes next. It is **lightweight** — not a full audit. For a full
gap analysis, use `/cc-project-stage-detect`.

---

## Step 1: Read the Catalog

Use `read_file` to read the workflow catalog (e.g., `docs/workflow-catalog.yaml` or equivalent).
This is the authoritative list of all phases, their steps (in order), whether each step is
required or optional, and the artifact globs that indicate completion.

If no workflow catalog exists, fall back to inferring phases from the standard CCGS pipeline:
concept → systems-design → technical-setup → pre-production → production → polish → release.

---

## Step 1b: Find Skills Not in the Catalog

After reading the catalog, use `file_search` with the pattern `skills/cc-*/SKILL.md` to get
the full list of installed cc- skills. For each file, use `read_file` to extract the `name:`
field from its frontmatter.

Compare against the catalog commands. Any skill whose name does not appear as a catalog
command is an **uncataloged skill** — still usable but not part of the phase-gated workflow.

Collect these for the output in Step 7 — show them as a footer block:

```
### Also installed (not in workflow)
- `/cc-skill-name` — [description from SKILL.md frontmatter]
- `/cc-skill-name` — [description]
```

Only show this block if at least one uncataloged skill exists. Limit to the 10
most relevant based on the user's current phase (QA skills in production, team
skills in production/polish, etc.).

---

## Step 2: Determine Current Phase

Check in this order:

1. **Read `production/stage.txt`** — use `file_search` for `**/stage.txt`. If it exists
   and has content, use `read_file` to get the authoritative phase name. Map it to a
   catalog phase key:
   - "Concept" → `concept`
   - "Systems Design" → `systems-design`
   - "Technical Setup" → `technical-setup`
   - "Pre-Production" → `pre-production`
   - "Production" → `production`
   - "Polish" → `polish`
   - "Release" → `release`

2. **If stage.txt is missing**, infer phase from artifacts (most-advanced match wins):
   - `src/` has 10+ source files → `production`
   - `production/stories/*.md` exists → `pre-production`
   - `docs/architecture/adr-*.md` exists → `technical-setup`
   - `design/gdd/systems-index.md` exists → `systems-design`
   - `design/gdd/game-concept.md` exists → `concept`
   - Nothing → `concept` (fresh project)

---

## Step 3: Read Session Context

Use `file_search` for `**/session-state/active.md`. If it exists, use `read_file` to extract:
- What was most recently worked on
- Any in-progress tasks or open questions
- Current epic/feature/task from STATUS block (if present)

This tells you what the user just finished or is stuck on — use it to personalize the output.

---

## Step 4: Check Step Completion for the Current Phase

For each step in the current phase (from the catalog):

### Artifact-based checks

If the step has `artifact.glob`:
- Use `file_search` to check if files matching the pattern exist
- If `min_count` is specified, verify at least that many files match
- If `artifact.pattern` is specified, use `grep_search` to verify the pattern exists in the matched file
- **Complete** = artifact condition is met
- **Incomplete** = artifact is missing or pattern not found

If the step has `artifact.note` (no glob):
- Mark as **MANUAL** — cannot auto-detect, will ask user

If the step has no `artifact` field:
- Mark as **UNKNOWN** — completion not trackable (e.g. repeatable implementation work)

### Special case: production phase — read `sprint-status.yaml`

When the current phase is `production`, use `file_search` for `**/sprint-status.yaml`.
If it exists, use `read_file` to read it directly:

- Stories with `status: in-progress` → surface as "currently active"
- Stories with `status: ready-for-dev` → surface as "next up"
- Stories with `status: done` → count as complete
- Stories with `status: blocked` → surface as blocker with the `blocker` field

This gives precise per-story status without markdown scanning. Skip the glob
artifact check for the `implement` and `story-done` steps — the YAML is authoritative.

### Special case: `repeatable: true` (non-production)

For repeatable steps outside production (e.g. "System GDDs"), the artifact
check tells you whether *any* work has been done, not whether it's finished.
Label these differently — show what's been detected, then note it may be ongoing.

---

## Step 5: Find Position and Identify Next Steps

From the completion data, determine:

1. **Last confirmed complete step** — the furthest completed required step
2. **Current blocker** — the first incomplete *required* step (this is what the
   user must do next)
3. **Optional opportunities** — incomplete *optional* steps that can be done
   before or alongside the blocker
4. **Upcoming required steps** — required steps after the current blocker
   (show as "coming up" so user can plan ahead)

If the user provided an argument (e.g. "just finished cc-design-review"), use that
to advance past the step they named even if the artifact check is ambiguous.

---

## Step 6: Check for In-Progress Work

If `active.md` shows an active task or epic:
- Surface it prominently at the top: "It looks like you were working on [X]"
- Suggest continuing it or confirm if it's done

---

## Step 7: Present Output

Keep it **short and direct**. This is a quick orientation, not a report.

```
## Where You Are: [Phase Label]

**In progress:** [from active.md, if any]

### ✓ Done
- [completed step name]
- [completed step name]

### → Next up (REQUIRED)
**[Step name]** — [description]
Command: `/cc-[command]`

### ~ Also available (OPTIONAL)
- **[Step name]** — [description] → `/cc-[command]`
- **[Step name]** — [description] → `/cc-[command]`

### Coming up after that
- [Next required step name] (`/cc-[command]`)
- [Next required step name] (`/cc-[command]`)

---
Approaching **[next phase]** gate → run `/cc-gate-check` when ready.
```

**Formatting rules:**
- `✓` for confirmed complete
- `→` for the current required next step (only one — the first blocker)
- `~` for optional steps available now
- Show commands inline as backtick code
- If a step has no command (e.g. "Implement Stories"), explain what to do instead of showing a slash command
- For MANUAL steps, ask the user: "I can't tell if [step] is done — has it been completed?"

Verdict: **COMPLETE** — next steps identified.

---

## Step 8: Gate Warning (if close)

After the current phase's steps, check if the user is likely approaching a gate:
- If all required steps in the current phase are complete (or nearly complete),
  add: "You're close to the **[Current] → [Next]** gate. Run `/cc-gate-check` when ready."
- If multiple required steps remain, skip the gate warning — it's not relevant yet.
