---
name: tic-prd-review
description: Use when reviewing an existing PRD or deciding whether a product baseline is ready to authorize durable implementation.
---

# TIC PRD Review Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/prd-review-checklist.md`.
5. Do not copy TIC Skills into project-local or global skills.

If the checklist is missing, report the gap and review only outcome, users, journey,
scope, non-goals, acceptance, evidence, conflicts, and authorization state.
