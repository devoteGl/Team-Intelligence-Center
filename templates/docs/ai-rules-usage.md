# AI Rules Usage

This project is connected to Team-Intelligence-Center in lightweight mode.

## What Was Installed

- `AGENTS.md`: project-level AI collaboration entrypoint.
- `.tic-rules.lock`: lightweight install metadata for diagnostics.
- `docs/ai-rules-usage.md`: this usage note.
- `ai-harness/project-adapter.md`: project-specific commands and risk notes.

## How To Work With AI

Use normal language first. The AI should route work by risk:

- Consulting and read-only work should stay direct.
- Micro changes should stay narrow and verified.
- Standard changes should use the relevant TIC skills and tests.
- Critical changes should require explicit confirmation and rollback thinking.

## Rule Source

Team-Intelligence-Center source path:

```text
{{TIC_RULES_DIR}}
```

Keep the source rules as the stable knowledge base. Do not copy large workflow packages, vendor assets, or historical PRD archives into this project unless the team explicitly decides to.

