# Team-Intelligence-Center Lightweight Rules

This project uses Team-Intelligence-Center as a lightweight AI collaboration rules layer.

Rules source: `{{TIC_RULES_DIR}}`
Rules version: `{{TIC_VERSION}}`

## Operating Principles

- Keep simple tasks simple. Do not run a full PRD/SDD/Plan process for consulting, read-only lookup, explanation, or tiny non-behavioral edits.
- Use SDD + TDD for standard and critical changes. Clarify the behavior spec first, then write or update tests against that spec before implementation.
- Use OpenSpec when this project has `openspec/` or the task crosses modules, APIs, data models, or long-lived product behavior. If OpenSpec is not present, keep the SDD in `docs/sdd/` or the nearest project-approved spec location.
- Escalate by risk, not by keyword. Payment, auth, data migration, production config, security, deletion, and cross-module contracts require stricter handling.
- Read local project context before changing code. Prefer existing patterns, commands, tests, and documentation.
- Verify before claiming completion. Report commands run, what passed, what was not tested, and remaining risks.
- Do not invent business facts. Mark inferred behavior and candidate rules with confidence before turning them into requirements.
- Do not overwrite human work. Preserve existing project rules and user changes.

## Task Routing

| Tier | Use When | Required Handling |
| --- | --- | --- |
| consulting | Explanation, comparison, read-only review, process discussion | Answer directly with evidence. Do not modify files. |
| micro | Copy, comments, documentation, tiny non-behavioral edits | Make the narrow change and run the smallest meaningful verification. |
| standard | New feature, behavior change, API/UI contract, cross-module work | Write or update an SDD, derive TDD tests from acceptance criteria, implement, then verify. |
| critical | Payment, auth, security, production config, destructive migration, data loss risk | Require explicit human confirmation, SDD + TDD evidence, rollback thinking, stronger verification, and clear release notes. |

## SDD + TDD Principle

- SDD defines the intended behavior, scope, non-goals, acceptance criteria, and edge cases.
- TDD turns those acceptance criteria into failing tests or explicit verification checks before implementation.
- Implementation should stay traceable to the SDD and the tests.
- OpenSpec may be the storage and lifecycle format for SDD artifacts, but it is not required for consulting or micro tasks.
- Do not treat undocumented inference as confirmed behavior. Use confidence labels and candidate rules for reconstructed legacy behavior.

## Recommended TIC Assets

- Global behavior rules: `Global-Rules/coding-rules.md`
- New requirements: `Prompts/ai-prd-generator.rules.md`
- Legacy reconstruction: `Prompts/ai-prd-editor.rules.md`
- OpenSpec / Superpowers integration: `Design/development-paradigm-openspec-guide.md`
- Investigation: `Skills/code-investigator.md`
- Task breakdown: `Skills/task-decomposer.md`
- API contract freeze: `Skills/api-contract-freezer.md`
- Candidate rule extraction: `Skills/candidate-rule-extractor.md`
- Release handoff: `Skills/release-ops-handoff.md` and `Skills/release-train-handoff.md`

## Completion Report

For code or documentation changes, final reports should include:

- Changed files.
- Simplifications or decisions made.
- Verification commands and results.
- Known gaps or remaining risks.
