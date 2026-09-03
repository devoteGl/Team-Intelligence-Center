---
name: tic-post-dev-prd-sync
description: Use when product maintainers need an evidence-based PRD update for delivered behavior; never promotes inferred rules automatically.
---

# TIC Post Dev PRD Sync Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/post-dev-prd-sync.md`.
5. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, report that and return only a consumer-scoped draft based on currently available delivery evidence; do not invent artifact roots or promote inferred rules.
