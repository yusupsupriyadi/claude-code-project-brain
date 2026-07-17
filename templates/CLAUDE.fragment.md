# Development Environment

- Operating system: Windows native.
- Default shell: PowerShell.
- This project does not use WSL.
- Use PowerShell-compatible commands and Windows paths.
- Do not use Bash-only commands unless explicitly requested.
- Preserve existing project conventions and configuration.

# Knowledge Priority

Use project knowledge in this order:

1. Read `.wolf/STATUS.md` for the current project state.
2. Read `.wolf/anatomy.md` for file and symbol navigation.
3. Read relevant permanent documentation under `docs/`.
4. Query Graphify for architecture relationships, dependencies, call flow,
   data flow, and impact analysis.
5. Read source files directly for verification and implementation.

Do not scan or read the entire repository when OpenWolf or Graphify already
provides enough context.

# OpenWolf Responsibilities

Use OpenWolf for:

- Current session handoff.
- Project file and symbol index.
- Previously fixed bugs.
- User corrections and project preferences.
- Avoiding repeated file reads.
- Tracking work completed during a session.

Do not manually duplicate `.wolf/memory.md` into `docs/`.

# Graphify Responsibilities

Use Graphify when:

- Investigating relationships between modules.
- Tracing request, event, or data flow.
- Evaluating the impact of structural changes.
- Understanding unfamiliar architecture.
- OpenWolf anatomy does not provide enough relationship context.

Prefer scoped Graphify queries over reading all of `GRAPH_REPORT.md`.
Refresh the graph after significant architecture or module changes.

# Obsidian Documentation

The project root is also an Obsidian Vault.

Permanent documentation belongs under `docs/`:

- `docs/architecture/`: system architecture and major flows.
- `docs/decisions/`: architecture decision records.
- `docs/features/`: feature behavior and requirements.
- `docs/bugs/`: important bug investigations and root causes.
- `docs/sessions/`: meaningful development summaries only.

Use Obsidian internal links with the `[[Note Name]]` format.

# Documentation Policy

Update `docs/` only when work changes:

- Architecture.
- Product behavior.
- Public API contracts.
- Important technical decisions.
- Significant bugs and root causes.
- Operational or deployment procedures.

Temporary activity belongs in OpenWolf memory and STATUS files.

Never write secrets, access tokens, credentials, private keys, or `.env`
contents into OpenWolf notes, Graphify documentation, or Obsidian notes.

# Completion Checklist

After significant work:

1. Run relevant tests and validation.
2. Update permanent documentation only when needed.
3. Record important architecture decisions as ADRs.
4. Update OpenWolf project state.
5. Refresh Graphify if code structure changed significantly.
6. Report files changed, validation performed, and remaining risks.
