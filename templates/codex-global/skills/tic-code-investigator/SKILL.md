---
name: tic-code-investigator
description: Use when the user asks to map, explain, or trace existing code behavior, or when an unknown implementation fact blocks a current decision.
---

# TIC Code Investigator Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/code-investigator.md`.
5. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, perform a lightweight read-only investigation and clearly mark unresolved gaps.
