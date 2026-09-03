---
name: tic-shared-domain-arbiter
description: Use when concurrent owners have a real ownership or solution conflict while modifying the same shared domain.
---

# TIC Shared Domain Arbiter Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Prefer `<rules_dir>/Skills/shared-domain-arbiter.md`.
5. If missing, fall back to `<rules_dir>/Skills/conflict-arbiter.md`.
6. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, report the missing rule and unresolved ownership conflict; do not infer an arbitration decision.
