---
name: tic-contract-handoff
description: Use when a shared contract crosses implementation boundaries and independent consumers need compatible semantics, versioning, or migration decisions.
---

# TIC Contract Handoff Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has a non-empty `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Prefer `<rules_dir>/Skills/contract-handoff.md`.
5. If missing, fall back to `<rules_dir>/Skills/api-contract-freezer.md` and `<rules_dir>/Skills/fe-be-handoff.md`.
6. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, report the missing rule and return only the contract facts already known; do not infer a mandatory handoff.
