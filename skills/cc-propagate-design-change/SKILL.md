---
name: cc-propagate-design-change
description: "When a GDD is revised, scans all ADRs and the traceability index to identify which architectural decisions are now potentially stale. Produces a change impact report and guides the user through resolution."
---

# Propagate Design Change

When a GDD changes, architectural decisions written against it may no longer be
valid. This skill finds every affected ADR, compares what the ADR assumed against
what the GDD now says, and guides the user through resolution.

**Usage:** `/cc-propagate-design-change design/gdd/combat-system.md`

---

## 1. Validate Argument

A GDD path argument is **required**. If missing, fail with:
> "Usage: `/cc-propagate-design-change design/gdd/[system].md`"

Verify the file exists using `file_search`. If not found, fail.

---

## 2. Read the Changed GDD

Use `read_file` on the current GDD in full.

---

## 3. Read the Previous Version

Use `run_in_terminal` to get the previous committed version:

```bash
git show HEAD:design/gdd/[filename].md
```

If no git history (new file), report:
> "No previous version — this appears to be a new GDD. Nothing to propagate."

If git returns the previous version, produce a change summary:

```
## Change Summary: [GDD filename]
Date of revision: [today]

Changed sections:
- [Section name]: [what changed]

Unchanged sections:
- [Section name]

Key changes affecting architecture:
- [Change 1]
- [Change 2]
```

---

## 4. Load Architecture Inputs

Use `file_search` for `docs/architecture/adr-*.md` and `read_file` each:
- Extract "GDD Requirements Addressed" table
- Note which GDD documents and requirement IDs each ADR references

Use `read_file` on `docs/architecture/architecture-traceability.md` if it exists.

Report: "Loaded [N] ADRs. [M] reference [gdd filename]."

---

## 5. Impact Analysis

For each ADR that references the changed GDD:

Compare the ADR's "GDD Requirements Addressed" entries against changed sections.

1. **Locate the requirement** in the current GDD — does it still exist?
2. **Compare**: What did the GDD say when the ADR was written vs. now?
3. **Assess**: Is the architectural decision still valid?

Classify each affected ADR:

| Status | Meaning |
|--------|---------|
| ✅ **Still Valid** | GDD change doesn't affect this ADR |
| ⚠️ **Needs Review** | GDD change may affect this ADR |
| 🔴 **Likely Superseded** | GDD change directly contradicts ADR assumptions |

For each affected ADR, produce an impact entry:

```
### ADR-NNNN: [title]
Status: [Still Valid / Needs Review / Likely Superseded]

What the ADR assumed:
  "[relevant quote from ADR]"

What the GDD now says:
  "[relevant quote from current GDD]"

Assessment:
  [Is the ADR decision still valid?]

Recommended action:
  [Keep as-is | Review and update | Mark Superseded and write new ADR]
```

---

## 6. Present Impact Report

```
## Design Change Impact Report
GDD: [filename]
Date: [today]
Changes detected: [N sections changed]
ADRs referencing this GDD: [M]

### Not Affected
[ADRs whose decisions remain valid]

### Needs Review ([count])
[ADRs that may need updating]

### Likely Superseded ([count])
[ADRs whose assumptions are contradicted]
```

---

## 6b. Director Gate — Technical Impact Review

**Review mode check**:
- `solo` → skip. Proceed to Phase 7.
- `lean` → skip. Proceed to Phase 7.
- `full` → spawn `cc-lead-programmer` via `runSubagent` to review the impact classifications.

Apply the verdict:
- **APPROVE** → proceed to Phase 7
- **CONCERNS** → surface via `vscode_askQuestions`
- **REJECT** → re-analyze before continuing

---

## 7. Resolution Workflow

For each ADR marked "Needs Review" or "Likely Superseded", use `vscode_askQuestions` per ADR:

> "ADR-NNNN ([title]) — [status]. What would you like to do?"
> - "Mark Superseded (I'll write a new ADR)"
> - "Update in place (minor revision)"
> - "Keep as-is (change doesn't affect this decision)"
> - "Skip for now"

For ADRs marked **Superseded**:
- Update the Status field using `replace_string_in_file`
- Ask: "May I update the status in [ADR filename]?"

---

## 8. Update Traceability Index

If `docs/architecture/architecture-traceability.md` exists, update using `replace_string_in_file`:
- Add changed GDD requirements to the "Superseded Requirements" table

Ask: "May I update the traceability index?"

---

## 9. Output Change Impact Document

Ask: "May I write the change impact report to `docs/architecture/change-impact-[date]-[system-slug].md`?"

Use `create_file` to write the document containing:
- Change summary from step 3
- Full impact analysis from step 5
- Resolution decisions from step 7
- List of ADRs that need to be written or updated

---

## 10. Follow-Up Actions

Based on resolutions, suggest:
- **ADRs marked Superseded**: "Run `/cc-architecture-decision [title]` for the replacement ADR."
- **ADRs to update in place**: List specific fields to update
- **If many ADRs affected**: "Run `/cc-architecture-review` after all updates to verify traceability."

---

## Collaborative Protocol

1. **Read silently** — compute the full impact before presenting
2. **Show the full report first** — let the user see scope before asking for action
3. **Ask per-ADR** — each affected ADR may need different treatment
4. **Ask before writing** — always confirm before modifying files
5. **Non-destructive** — never delete ADR content; only add "Superseded by" notes
