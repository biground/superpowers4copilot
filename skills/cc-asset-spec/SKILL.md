---
name: cc-asset-spec
description: "Generate per-asset visual specifications and AI generation prompts from GDDs, level docs, or character profiles. Produces structured spec files and updates the master asset manifest. Run after art bible and GDD/level design are approved, before production begins."
---

If no argument is provided, check whether `design/assets/asset-manifest.md` exists:
- If it exists: read it, find the first context with any asset at status "Needed" but no spec file, and use `vscode_askQuestions` to confirm the next target.
- If no manifest: fail with usage instructions.

---

## Phase 0: Parse Arguments

Extract:
- **Target type**: `system`, `level`, or `character`
- **Target name**: the name after the colon (normalize to kebab-case)
- **Review mode**: `--review [full|lean|solo]` if present

**Mode behavior:**
- `full` (default): spawn both `cc-art-director` and `cc-technical-artist` in parallel
- `lean`: spawn `cc-art-director` only — faster, skips technical constraint pass
- `solo`: no agent spawning — main session writes specs from art bible rules alone

---

## Phase 1: Gather Context

Read all source material **before** asking the user anything.

### Required reads:
- **Art bible**: Use `read_file` on `design/art/art-bible.md` — fail if missing:
  > "No art bible found. Run `/cc-art-bible` first."
  Extract: Visual Identity Statement, Color System, Shape Language, Asset Standards (Section 8).

- **Technical preferences**: Read the project technical preferences file.

### Source doc reads (by target type):
- **system**: Use `read_file` on `design/gdd/[target-name].md`. Extract the **Visual/Audio Requirements** section.
- **level**: Use `read_file` on `design/levels/[target-name].md`. Extract art requirements.
- **character**: Search `design/narrative/` for the character profile.

### Optional reads:
- **Existing manifest**: Read `design/assets/asset-manifest.md` if it exists.
- **Related specs**: Use `file_search` for `design/assets/specs/*.md`.

### Present context summary before proceeding.

---

## Phase 2: Asset Identification

From the source doc, extract every asset type mentioned — explicit and implied.

Group assets into categories:
- **Sprite / 2D Art** — character sprites, UI icons, tile sheets
- **VFX / Particles** — hit effects, ambient particles, screen effects
- **Environment** — props, tiles, backgrounds, skyboxes
- **UI** — HUD elements, menu art, fonts (if custom)
- **Audio** — SFX, music tracks, ambient loops *(descriptions only — no generation prompts)*
- **3D Assets** — meshes, materials (if applicable per engine)

Present the full list. Use `vscode_askQuestions`:
- Options: `[A] Proceed — spec all` / `[B] Remove some` / `[C] Add assets` / `[D] Adjust categories`

---

## Phase 3: Spec Generation

Spawn specialist agents based on review mode. **Issue all `runSubagent` calls simultaneously.**

### Full mode — spawn in parallel:

**`cc-art-director`** via `runSubagent`:
- Provide: full asset list, art bible context, source doc visual requirements
- Ask: produce visual descriptions, generation prompts, and art bible rule citations for each asset

**`cc-technical-artist`** via `runSubagent`:
- Provide: full asset list, art bible Asset Standards, technical preferences, engine info
- Ask: specify dimensions, file format, naming conventions, engine constraints, LOD requirements

### Lean mode — spawn `cc-art-director` only.
### Solo mode — skip both. Derive from art bible rules alone.

**Collect both responses before Phase 4.** Surface any conflicts explicitly.

---

## Phase 4: Compile and Review

Combine agent outputs into a draft spec per asset:

```
## ASSET-[NNN] — [Asset Name]

| Field | Value |
|-------|-------|
| Category | [Sprite / VFX / Environment / UI / Audio / 3D] |
| Dimensions | [e.g. 256×256px, 4-frame sprite sheet] |
| Format | [PNG / SVG / WAV / etc.] |
| Naming | [e.g. vfx_frost_hit_01.png] |
| Polycount | [if 3D] |
| Texture Res | [e.g. 512px — matches Art Bible §8 Tier 2] |

**Visual Description:**
[2–3 sentences.]

**Art Bible Anchors:**
- §3 Shape Language: [relevant rule]
- §4 Color System: [color role]

**Generation Prompt:**
[Ready-to-use prompt with style keywords, composition, color anchors, negative prompts.]

**Status:** Needed
```

Use `vscode_askQuestions`:
- Options: `[A] Approve all — write to file` / `[B] Revise a specific asset` / `[C] Regenerate with different direction`

---

## Phase 5: Write Spec File

After approval, use `create_file` to write `design/assets/specs/[target-name]-assets.md`.

Then update `design/assets/asset-manifest.md`. If it doesn't exist, create it with progress summary and assets by context.

---

## Phase 6: Close

Use `vscode_askQuestions`:
- Prompt: "Asset specs complete for **[target]**. What's next?"
- Options:
  - `[A] Spec next target`
  - `[B] Begin production`
  - `[C] Stop here`
