---
name: tic-prd-author
description: Use when creating or confirming a PRD or when a greenfield product or major user journey lacks a confirmed product baseline.
---

# TIC PRD Author Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Resolve the project rules source from `.tic-rules.lock`, then `.tic-rules.local`.
2. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
3. Read and follow `<rules_dir>/Skills/prd-author.md`.
4. For a full PRD draft, also read `<rules_dir>/Prompts/ai-prd-generator.rules.md`.
5. Do not copy TIC Skills into project-local or global skills.

If the capability is missing, return a product-baseline draft with explicit unknowns and
keep it unconfirmed; do not begin durable implementation from that fallback.
