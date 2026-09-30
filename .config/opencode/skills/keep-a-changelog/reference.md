# Keep a Changelog — Full Reference

Based on [Keep a Changelog v1.1.0](https://keepachangelog.com/en/1.1.0/).

## Guiding Principles

- Changelogs are for **humans**, not machines.
- There should be an entry for **every single version**.
- The **same types of changes** should be grouped.
- Versions and sections should be **linkable**.
- The **latest version comes first**.
- The **release date** of each version is displayed.
- Mention whether you follow **Semantic Versioning**.

## The Six Change Types (with examples)

| Type         | When to use                                                 |
|--------------|-------------------------------------------------------------|
| `### Added`  | New features, translations, sections, endpoints.            |
| `### Changed` | Functional changes to existing behavior or presentation.   |
| `### Deprecated` | Features that will be removed in a future release.     |
| `### Removed` | Features fully removed in this release.                   |
| `### Fixed`  | Bug fixes, typo corrections, broken links.                  |
| `### Security` | Vulnerability patches, dependency upgrades for CVEs.     |

**Order is significant** — always list sections in the order above. Omit empty sections.

## Detailed Format Rules

### Version heading

```
## [X.Y.Z] - YYYY-MM-DD
```

- Surround the version number in **square brackets**.
- Separate version and date with ` - ` (space, hyphen, space).
- Use **ISO 8601** dates: `2026-04-28`, not `28/04/2026` or `April 28, 2026`.

### Yanked releases

```
## [0.0.5] - 2014-12-13 [YANKED]
```

- `[YANKED]` is **loud** for a reason — it must be hard to miss.
- Square brackets make it parseable by scripts.
- Never remove the yanked version from the file.

### Date format rationale

ISO 8601 goes from largest to smallest unit (year → month → day) and avoids regional ambiguity (e.g., `07/08/2025` could be July 8 or August 7 depending on locale).

## Version Diff Links

Add reference-style links at the bottom of the file so readers can compare versions:

```md
[unreleased]: https://github.com/owner/repo/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/owner/repo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/owner/repo/releases/tag/v1.0.0
```

- The first line compares the `HEAD` of the default branch to the latest tag.
- Each subsequent line compares the tag to its predecessor.
- The oldest version links directly to its release/tag page (no diff available).

## Bad Practices to Avoid

### 1. Commit log diffs

Never dump `git log` output into a changelog. Commits are for source-code archeology; changelogs are a curated summary for end users.

### 2. Ignoring deprecations

Always list deprecations, removals, and breaking changes. Users should be able to upgrade to a version that announces deprecations, remove the deprecated usage, *then* upgrade to the version that removes it.

### 3. Confusing dates

Always use `YYYY-MM-DD`. Never use regional formats like `04/28/2026` or `28.04.2026`.

### 4. Inconsistent changes

If an important change isn't in the changelog, users lose trust. Apply the convention consistently.

## File Naming

Use `CHANGELOG.md`. Some projects use `HISTORY`, `NEWS`, or `RELEASES`, but `CHANGELOG.md` is the most discoverable convention and mirrors `README.md`, `CONTRIBUTING.md`, etc.

## GitHub Releases vs. CHANGELOG.md

GitHub Releases are non-portable (tied to GitHub) and less discoverable than a file in the repository root. Use GitHub Releases as a *supplement*, not a replacement, for `CHANGELOG.md`.

## Migration Cheat Sheet

| From              | To                                                  |
|-------------------|------------------------------------------------------|
| No changelog      | Create `CHANGELOG.md` from scratch with `[Unreleased]` |
| Bare git tags     | Create a proper `CHANGELOG.md` and backfill entries   |
| `NEWS` / `HISTORY` | Rename to `CHANGELOG.md` and adopt this format       |
| Bulleted dump     | Restructure under the six change-type headings        |

## Full Example (truncated)

```
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Dark mode support (#234).

### Fixed
- Crash on empty search query (#230).

## [2.0.0] - 2026-03-15
### Changed
- **Breaking:** drop support for Node.js 16.

### Security
- Patch ReDoS in path parser.

## [1.0.0] - 2026-01-10 [YANKED]
### Added
- Initial stable release.

[unreleased]: https://github.com/owner/repo/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/owner/repo/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/owner/repo/releases/tag/v1.0.0
```
