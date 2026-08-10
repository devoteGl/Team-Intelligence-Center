---
name: tic-release-handoff
description: Use when an independent release, operations, QA, or usage consumer needs deployment, verification, monitoring, rollback, or takeover information.
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

If the target TIC Skill is missing, report the missing rule and provide only consumer-requested release facts backed by current evidence.
