---
name: tic-project-bootstrap
description: Use to connect a business project to Team-Intelligence-Center rules, project AGENTS, lightweight lock, usage docs, and project adapter files.
---

# TIC Project Bootstrap Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Prefer the current project's TIC installation scripts if already present.
2. If a project has `.tic-rules.lock`, prefer its non-empty project-relative `rules_path=`; otherwise use `.tic-rules.local` `rules_dir=` when present.
3. Otherwise use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/project-governance-bootstrap.md` when governance setup is requested.
5. For lightweight install, prefer `<rules_dir>/tools/install.sh` or `<rules_dir>/tools/install.ps1`.
6. Do not copy TIC Skills into project-local or global skills by default.

If the target TIC Skill is missing, use the lightweight install path: create or merge project `AGENTS.md`, write `.tic-rules.lock`, generate `docs/ai-rules-usage.md`, and generate `ai-harness/project-adapter.md`.
