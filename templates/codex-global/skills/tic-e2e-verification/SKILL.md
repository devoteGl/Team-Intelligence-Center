---
name: tic-e2e-verification
description: Use when local checks cannot prove an important user journey, cross-layer flow, authentication, permission, payment, privacy, migration, or cross-service behavior, including runner selection, safe test data, evidence, cleanup, and verdicts.
---

# TIC E2E Verification Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:

1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/e2e-verification.md`.
5. Read the project's `AGENTS.md` and `ai-harness/project-adapter.md` before choosing a runner, environment, auth method, data strategy, or evidence root.
6. Prefer project-native repeatable suites as the primary fact source. Treat Browser, Chrome, MCP, Computer Use, screenshots, and traces as replaceable adapters or observable evidence.
7. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, do not claim E2E passed. Produce a lightweight requirement decision, list the unavailable canonical rule, execute only safe project-native verification that is already documented, and report the result as `partial` or `blocked` with remaining risk.
