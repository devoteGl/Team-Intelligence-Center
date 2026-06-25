---
name: tic-release-ops-handoff
description: Compatibility wrapper. Prefer tic-release-handoff for single-change or release-train operations, QA, rollout, rollback, monitoring, and usage handoff.
---

# TIC Release Ops Handoff Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has a non-empty `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Prefer `<rules_dir>/Skills/release-handoff.md`.
5. If missing, read and follow `<rules_dir>/Skills/release-ops-handoff.md`.
6. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, produce a concise release handoff with scope, deploy steps, validation, rollback, known risks, and owner follow-ups.
