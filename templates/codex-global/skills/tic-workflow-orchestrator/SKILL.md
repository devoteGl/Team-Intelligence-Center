---
name: tic-workflow-orchestrator
description: Use as the Team-Intelligence-Center workflow router. Classifies risk, applies risk_floor, selects TIC Skills, OpenSpec, Superpowers, checkpoints, evidence, and closeout artifacts without copying child skill bodies.
---

# TIC Workflow Orchestrator Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has a non-empty `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/tic-workflow-orchestrator.md`.
5. Do not copy TIC Skills into project-local or global skills.
6. Route to child TIC Skills by reference; do not inline or duplicate child Skill templates.

If the target TIC Skill is missing, produce a lightweight plan card with risk tier, risk_floor, phases, selected skills, skipped skills and reasons, E2E requirement decision, OpenSpec/Superpowers integration points, checkpoints, required artifacts, and pending confirmations.
