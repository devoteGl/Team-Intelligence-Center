---
name: tic-code-investigator
description: Use for TIC-style codebase investigation, module mapping, business rule discovery, and risk scanning before non-trivial changes.
---

# TIC Code Investigator Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has a non-empty `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/code-investigator.md`.
5. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, perform a lightweight read-only investigation and clearly mark unresolved gaps.
