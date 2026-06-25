# Security Policy

## Supported Versions

Team-Intelligence-Center is currently published as a public preview rule pack. Security fixes are handled on the latest public branch unless a maintainer documents a different support window.

## Reporting a Vulnerability

Please do not open a public issue for sensitive security problems.

Use GitHub private vulnerability reporting if it is enabled on the repository. If it is not enabled yet, contact the repository maintainers through the project's listed maintainer channel and include:

- The affected file or script.
- Reproduction steps or a minimal example.
- Whether the issue may expose secrets, overwrite user files, or trigger unsafe Git/installation behavior.
- Any suggested mitigation.

## Scope

Security-relevant issues include:

- Secrets, credentials, or private infrastructure accidentally committed to the repository.
- Installation scripts writing unsafe files, skipping backups, or modifying user projects unexpectedly.
- Automation that performs Git push, merge, tag, branch deletion, or destructive file operations without explicit user confirmation.
- Prompt or rule behavior that encourages leaking private project data.

## Handling Expectations

Maintainers should acknowledge reports as soon as practical, avoid disclosing details until a fix is available, and credit reporters when they want public credit.
