# Project Documentation

This directory contains technical documentation for the manuscript, its build and release pipeline,
and the family style guide as it applies here.

## Structure

```
docs/
├── README.md          # This file
├── architecture.md    # Release system architecture
├── citations.md       # CSL single-source citation pipeline (§1–§7)
├── figures.md         # Deterministic figure pipeline
├── installation.md    # Prerequisites and setup
├── style-guide.md     # Family style guide v2.2 (port of `05-kkgt/docs/style-guide.md`)
├── style/
│   └── grammar.md     # Grammar and usage rules of human language (ES/EN/FR/IT examples)
├── usage.md           # Build, release, commit and version conventions (semver + Zenodo)
└── reports/           # Specific, repository-tied reports (dated, id'd)
    └── README.md      # Reports convention (template) + index of this repository's reports
```

## Contents

- **architecture.md**: Tech stack, execution flow, reproducibility measures, scripts structure.
- **citations.md**: How `citation.csl.json` drives the bibliography, CITATION.cff and .zenodo.json
  (§1–§7). The family witness contract is §8 of a repository's `citations.md`; this repository
  renders no witness marks, so it is not propagated here — `style-guide.md` links it instead.
- **figures.md**: What `pnpm run generate:figures` guarantees and why (byte-stable, text-extractable PDFs).
- **installation.md**: Prerequisites and setup instructions.
- **style-guide.md**: The family style guide (v2.2), a port of `05-kkgt/docs/style-guide.md`:
  editorial rules (§1–§12), including the rigorous IMRAD structure of §7; the software-quality
  doctrine D1–D7 (§13); the TeX/proofreading pipeline with its cited sources (§14). Generic across
  the family: this repository's own conventions are linked, never copied — `style/grammar.md` and
  `reports/` are propagated here (local links), while the witness contract `citations.md` §8 and
  `witness-contract.md` resolve to `05-kkgt` on GitHub, because this repository has no witness
  system to apply them to.
- **style/grammar.md**: The grammar and usage rules extracted from `style-guide.md` §1.5 —
  language-neutral, worked in Spanish, English, French and Italian, with the RAE-checked Spanish
  `se` verbs and their sources.
- **usage.md**: Daily workflow, conventional commits, the version standard (semver + Zenodo), build and release commands.
- **reports/**: Specific reports — per-site inventories, decision logs, verdict tables and
  incidents. The convention (naming, ISO header, index format) and the index of this repository's
  reports are in `reports/README.md`; this repository has no report yet.

## Conventions

Commits follow [Conventional Commits](https://www.conventionalcommits.org/);
format, common types, examples and the English-subject rule:
[usage.md](usage.md) §Commits.
