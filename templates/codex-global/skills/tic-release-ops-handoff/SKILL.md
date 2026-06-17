---
name: tic-release-ops-handoff
description: Use when a feature or cross-project change needs release, operations, QA, rollout, rollback, and usage handoff documentation.
---

# TIC Release Ops Handoff Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/release-ops-handoff.md`.
5. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, produce a concise release handoff with scope, deploy steps, validation, rollback, known risks, and owner follow-ups.
