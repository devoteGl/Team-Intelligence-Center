---
name: tic-api-contract-freezer
description: Use when the user explicitly invokes the legacy tic-api-contract-freezer name; re-evaluate the canonical contract-handoff activation boundary.
---

# TIC API Contract Freezer Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Prefer `<rules_dir>/Skills/contract-handoff.md`.
5. If missing, read and follow `<rules_dir>/Skills/api-contract-freezer.md`.
6. Do not copy TIC Skills into project-local or global skills.

If the canonical Skill is missing, report the missing rule; do not restore the legacy workflow.
