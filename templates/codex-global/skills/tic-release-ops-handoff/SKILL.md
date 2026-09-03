---
name: tic-release-ops-handoff
description: Use when the user explicitly invokes the legacy tic-release-ops-handoff name; re-evaluate the canonical release-handoff activation boundary.
---

# TIC Release Ops Handoff Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Prefer `<rules_dir>/Skills/release-handoff.md`.
5. If missing, read and follow `<rules_dir>/Skills/release-ops-handoff.md`.
6. Do not copy TIC Skills into project-local or global skills.

If the canonical Skill is missing, report the missing rule; do not restore the legacy release template.
