---
name: tic-project-bootstrap
description: Use when the user requests connecting, repairing, or updating a project's lightweight Team-Intelligence-Center entrypoints.
---

# TIC Project Bootstrap Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Prefer the current project's TIC installation scripts if already present.
2. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
3. Otherwise prefer `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
4. Otherwise use fallback rules source: `{{TIC_RULES_DIR}}`.
5. Read and follow `<rules_dir>/Skills/project-governance-bootstrap.md` when governance setup is requested.
6. For lightweight install, prefer `<rules_dir>/tools/install.sh` or `<rules_dir>/tools/install.ps1`.
7. Do not copy TIC Skills into project-local or global skills by default. Back up and remove only recognized legacy TIC project-local bundles; preserve unknown or project-owned skills.

If the target TIC Skill is missing, use the lightweight install path: create or merge project `AGENTS.md`, write `.tic-rules.lock`, generate `docs/ai-rules-usage.md`, and generate `ai-harness/project-adapter.md`.
