# Contributing

Thanks for helping improve Team-Intelligence-Center. This project is a Chinese-first, tool-neutral rule pack for AI-assisted engineering workflows.

## What Belongs Here

- Workflow rules, prompts, skills, templates, and lightweight automation that help teams coordinate AI coding work.
- Improvements that keep the system tool-neutral across Codex, Cursor, OpenSpec, Superpowers, and similar tools.
- Documentation that helps new users adopt the rules safely.

## Contribution Principles

- Keep the core flow readable before making it clever.
- Preserve high cohesion and low coupling between rules, skills, templates, and automation scripts.
- Do not add private organization names, internal repository URLs, secrets, personal machine paths, or customer-specific details.
- Keep automation lightweight: direct by default, no mandatory orchestrator, no default Git hooks, no forced branch operations, and no vendored binaries.
- Prefer evidence-based rules. If behavior is inferred from code, mark confidence instead of turning it into confirmed product truth.

## Local Validation

Run the package validator before opening a pull request:

```bash
bash tools/validate-pack.sh
```

If you change installation behavior, test a dry run against a disposable project:

```bash
bash tools/install.sh --preview /path/to/disposable-project
```

## Pull Request Checklist

- [ ] I ran `bash tools/validate-pack.sh`.
- [ ] I removed private URLs, personal paths, and organization-specific confidential context.
- [ ] I updated README/USAGE or templates if behavior changed.
- [ ] I kept generated/local files such as `.tic-rules.local`, `.tic-backups/`, `.omx/`, and `.superpowers/` out of Git.

## Commit Style

Use concise Conventional Commit style where possible, for example:

```text
docs(readme): clarify public preview setup
chore(repo): add open source governance files
```
