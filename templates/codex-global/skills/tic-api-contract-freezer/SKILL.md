---
name: tic-api-contract-freezer
description: Use before FE/BE parallel work or API-affecting changes to freeze request, response, field, error, permission, and version contracts.
---

# TIC API Contract Freezer Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; read `rules_dir=`.
2. If no lock exists, locate project `AGENTS.md` and find the TIC rules source.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/api-contract-freezer.md`.
5. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, produce a lightweight API contract draft and list all fields, behaviors, and decisions needing confirmation.
