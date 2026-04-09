---
description: "Use when modifying install.ps1 or install.sh. Enforces that both scripts are always updated together — never modify one without the other."
applyTo: "install.{ps1,sh}"
---

# Install Scripts Must Be Updated Together

`install.ps1` (Windows/PowerShell) and `install.sh` (macOS/Linux/Bash) are platform equivalents of the same installer. They must always stay in sync.

## Rule

**Whenever you modify `install.ps1` or `install.sh`, you MUST apply the equivalent change to the other file.**

Never complete a task that touches only one of these files. Always update both before considering the task done.

## Checklist Before Marking Done

- [ ] Change applied to `install.ps1`
- [ ] Equivalent change applied to `install.sh`
- [ ] Logic, flags, and behavior are consistent across both files
