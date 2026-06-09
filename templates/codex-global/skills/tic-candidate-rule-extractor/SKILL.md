---
name: tic-candidate-rule-extractor
description: Use to extract candidate business rules from existing code, UI constraints, API validation, tests, and git history with confidence labels.
---

# TIC Candidate Rule Extractor Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; read `rules_dir=`.
2. If no lock exists, locate project `AGENTS.md` and find the TIC rules source.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/candidate-rule-extractor.md`.
5. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, extract only candidate rules with source evidence and confidence labels; never promote inferred rules automatically.
