---
name: tic-shared-domain-arbiter
description: Use when a change needs to modify shared domains such as router, types, constants, global config, public utilities, or contract files during parallel or cross-module work.
---

# TIC Shared Domain Arbiter Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Prefer `<rules_dir>/Skills/shared-domain-arbiter.md`.
5. If missing, fall back to `<rules_dir>/Skills/conflict-arbiter.md`.
6. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, produce a lightweight shared-domain arbitration card with requested file/domain, change type, scope, FE/BE/QA impact, decision, conditions, owners to notify, and pending confirmations.
