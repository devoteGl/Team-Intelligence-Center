---
name: tic-prd-author
description: Use when creating or confirming a PRD or when a greenfield product or major user journey lacks a confirmed product baseline.
---

# TIC PRD Author Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/prd-author.md`.
5. For a full PRD draft, also read `<rules_dir>/Prompts/ai-prd-generator.rules.md`.
6. Do not copy TIC Skills into project-local or global skills.

If the capability is missing, return a product-baseline draft with explicit unknowns and
keep it unconfirmed; do not begin durable implementation from that fallback.
