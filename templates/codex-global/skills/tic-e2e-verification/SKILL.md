---
name: tic-e2e-verification
description: Use when local checks cannot prove an important user journey, cross-layer flow, authentication, permission, payment, privacy, migration, or cross-service behavior, including runner selection, safe test data, evidence, cleanup, and verdicts.
---

# TIC E2E Verification Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:

1. Locate the current project's `.tic-rules.lock`; if it has a non-empty `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/e2e-verification.md`.
5. Read the project's `AGENTS.md` and `ai-harness/project-adapter.md` before choosing a runner, environment, auth method, data strategy, or evidence root.
6. Prefer project-native repeatable suites as the primary fact source. Treat Browser, Chrome, MCP, Computer Use, screenshots, and traces as replaceable adapters or observable evidence.
7. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, do not claim E2E passed. Produce a lightweight requirement decision, list the unavailable canonical rule, execute only safe project-native verification that is already documented, and report the result as `partial` or `blocked` with remaining risk.
