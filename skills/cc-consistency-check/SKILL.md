---
name: cc-consistency-check
description: "Scan all GDDs against the entity registry to detect cross-document inconsistencies: same entity with different stats, same item with different values, same formula with different variables. Grep-first approach — reads registry then targets only conflicting GDD sections rather than full document reads."
---

# Consistency Check

Detects cross-document inconsistencies by comparing all GDDs against the
entity registry (`design/registry/entities.yaml`). Uses a grep-first approach:
reads the registry once, then targets only the GDD sections that mention
registered names — no full document reads unless a conflict needs investigation.

**When to run:**
- After writing each new GDD (before moving to the next system)
- Before `/cc-review-all-gdds`
- Before `/cc-create-architecture`
- On demand: `/cc-consistency-check entity:[name]`

**Output:** Conflict report + optional registry corrections

---

## Phase 1: Parse Arguments and Load Registry

**Modes:**
- No argument / `full` — check all registered entries against all GDDs
- `since-last-review` — check only GDDs modified since last review
- `entity:<name>` — check one specific entity
- `item:<name>` — check one specific item

**Load the registry:**

Use `read_file` on `design/registry/entities.yaml`.

If the file does not exist or has no entries:
> "Entity registry is empty. Run `/cc-design-system` to write GDDs — the registry
> is populated automatically. Nothing to check yet."
Stop and exit.

Build four lookup tables:
- **entity_map**: `{ name → { source, attributes, referenced_by } }`
- **item_map**: `{ name → { source, value_gold, weight, ... } }`
- **formula_map**: `{ name → { source, variables, output_range } }`
- **constant_map**: `{ name → { source, value, unit } }`

Report:
```
Registry loaded: [N] entities, [N] items, [N] formulas, [N] constants
Scope: [full | since-last-review | entity:name]
```

---

## Phase 2: Locate In-Scope GDDs

Use `file_search` for `design/gdd/*.md`.

Exclude: `game-concept.md`, `systems-index.md`, `game-pillars.md`.

For `since-last-review`: use `run_in_terminal` with `git log --name-only` to find modified GDDs.

Report the in-scope GDD list.

---

## Phase 3: Grep-First Conflict Scan

For each registered entry, use `grep_search` on in-scope GDDs. Do NOT do full reads —
extract only matching lines and immediate context.

### 3a: Entity Scan

For each entity in entity_map:
```
grep_search query="[entity_name]" includePattern="design/gdd/*.md"
```

Compare extracted values against the registry entry.

**Conflict detection:**
- Registry says `[attribute] = [value_A]`. GDD says `[value_B]`. → **CONFLICT**
- GDD mentions entity but doesn't specify the attribute → **NOTE** (unverifiable)

### 3b: Item Scan

For each item in item_map, `grep_search` all GDDs. Extract and compare:
sell price, weight, stack rules, category.

### 3c: Formula Scan

For each formula, `grep_search` for the name. Compare variable names and output ranges.

### 3d: Constant Scan

For each constant, `grep_search` for the name. Compare numeric values.

---

## Phase 4: Deep Investigation (Conflicts Only)

For each conflict from Phase 3, use `read_file` on the conflicting GDD's relevant section for full context.

Determine:
1. **Which GDD is correct?** The `source:` field in the registry is authoritative.
2. **Is the registry stale?** Check if source GDD was updated after registry entry.
3. **Is this intentional?** If so, update source GDD, registry, and all other GDDs.

Classify each conflict:
- **🔴 CONFLICT** — different values. Must resolve before architecture begins.
- **⚠️ STALE REGISTRY** — source GDD changed but registry not updated.
- **ℹ️ UNVERIFIABLE** — mentioned but no comparable attribute stated.

---

## Phase 5: Output Report

```
## Consistency Check Report
Date: [date]
Registry entries checked: [N entities, N items, N formulas, N constants]
GDDs scanned: [N] ([list names])

---

### Conflicts Found (must resolve before architecture)

🔴 [Entity/Item/Formula/Constant Name]
   Registry (source: [gdd]): [attribute] = [value]
   Conflict in [other_gdd].md: [attribute] = [different_value]
   → Resolution needed: [which doc to change]

---

### Stale Registry Entries

⚠️ [Entry Name]
   Registry says: [value]
   Source GDD now says: [new value]
   → Update registry entry.

---

### Unverifiable References

ℹ️ [gdd].md mentions [name] but states no comparable attributes.

---

### Clean Entries

✅ [N] registry entries verified with no conflicts.

---

Verdict: PASS | CONFLICTS FOUND
```

---

## Phase 6: Registry Corrections

If stale registry entries were found, ask:
> "May I update `design/registry/entities.yaml` to fix the [N] stale entries?"

Use `replace_string_in_file` for each stale entry:
- Update the value/attribute field
- Set `revised:` to today's date
- Add a YAML comment with the old value

If new entries found in GDDs not in registry, ask:
> "Found [N] entities/items not in the registry. May I add them?"

Only add entries appearing in more than one GDD.

**Never delete registry entries.** Set `status: deprecated` if removed from all GDDs.

### 6b: Append to Reflexion Log

If 🔴 CONFLICT entries were found, append to `docs/consistency-failures.md` (if it exists):

```markdown
### [YYYY-MM-DD] — /cc-consistency-check — 🔴 CONFLICT
**Domain**: [system domain(s)]
**Documents involved**: [source GDD] vs [conflicting GDD]
**What happened**: [specific conflict]
**Resolution**: [how fixed, or "Unresolved"]
**Pattern**: [generalised lesson]
```

Only append if the file exists. Do not create it from this skill.

---

## Next Steps

- **If PASS**: Run `/cc-review-all-gdds` for holistic review, or `/cc-create-architecture` if all MVP GDDs are complete.
- **If CONFLICTS FOUND**: Fix flagged GDDs, then re-run `/cc-consistency-check`.
- **If STALE REGISTRY**: Update registry (Phase 6), then re-run to verify.
- Run `/cc-consistency-check` after writing each new GDD to catch issues early.
