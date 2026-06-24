---
name: tic-contract-handoff
description: Use before API, FE/BE, shared type, field, enum, error code, permission, or cross-end implementation work to freeze the contract and produce FE/BE handoff artifacts.
---

# TIC Contract Handoff Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Prefer `<rules_dir>/Skills/contract-handoff.md`.
5. If missing, fall back to `<rules_dir>/Skills/api-contract-freezer.md` and `<rules_dir>/Skills/fe-be-handoff.md`.
6. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, produce a lightweight frozen contract and FE/BE handoff checklist with fields, errors, rules, Mock data, self-test items, integration scenarios, and pending confirmations.
