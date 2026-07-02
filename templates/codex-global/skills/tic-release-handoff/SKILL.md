---
name: tic-release-handoff
description: Use when a feature, service, release train, SQL/script, or cross-project change needs deployment, operations, QA, rollback, monitoring, usage, and feedback-loop handoff.
---

# TIC Release Handoff Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has a non-empty `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Prefer `<rules_dir>/Skills/release-handoff.md`.
5. If missing, fall back to `<rules_dir>/Skills/release-ops-handoff.md` for single-change handoff or `<rules_dir>/Skills/release-train-handoff.md` for release-train handoff.
6. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, produce a release handoff with mode single/train, release owner, release registry root, release tag, tag target commit, remote tag status, SDD/TDD/PRD landing status, scope, deploy steps, validation, operations/usage notes, monitoring, rollback, evidence, risks, and pending confirmations.
