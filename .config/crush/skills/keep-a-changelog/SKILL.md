---
name: keep-a-changelog
description: Create and maintain a CHANGELOG.md following the Keep a Changelog v1.1.0 convention. Use when a user asks to create a changelog, update a changelog, cut a release, track changes, or mentions "keep a changelog", "CHANGELOG.md", or "release notes".
---

# Keep a Changelog

## Creating a changelog

Create a `CHANGELOG.md` file with this skeleton:

```md
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - YYYY-MM-DD
### Added
- Initial release.
```

Always put the `[Unreleased]` section at the top, followed by releases in **reverse chronological order** (newest first).

## Workflows

### 1. Adding a change (unreleased)

Find the `## [Unreleased]` section. If it doesn't exist, create one above the latest release. Add a bullet under the appropriate change type.

**Always group entries under one of these six headings:**

- `### Added` – new features
- `### Changed` – changes in existing functionality
- `### Deprecated` – soon-to-be removed features
- `### Removed` – now removed features
- `### Fixed` – bug fixes
- `### Security` – vulnerability fixes

**Order the sections as listed above.** If a section has no entries, omit it entirely.

**Example:**

```md
## [Unreleased]
### Fixed
- Handle null pointer in login flow (#123).

### Security
- Upgrade bcrypt to v2.0.1 to patch CVE-2024-xxxx.
```

### 2. Cutting a release

1. Replace `## [Unreleased]` with `## [X.Y.Z] - YYYY-MM-DD` using today's date in ISO 8601 format.
2. Immediately below that, create a new empty `## [Unreleased]` section.
3. Add a version comparison link at the bottom of the file (see [reference.md](reference.md)).

### 3. Yanking a release

If a release must be pulled due to a serious bug or security issue, append `[YANKED]` immediately after the date:

```md
## [0.0.5] - 2014-12-13 [YANKED]
```

Never delete a yanked release entry — it stays in the changelog so users know it existed.

### 4. Formatting rules (quick reference)

- **Dates**: ISO 8601 (`YYYY-MM-DD`)
- **File name**: `CHANGELOG.md` (case-insensitive; `CHANGELOG.md` preferred)
- **Version headings**: `## [X.Y.Z] - YYYY-MM-DD`
- **Unreleased heading**: `## [Unreleased]`
- **Entry bullets**: `- Description of change (#PR).`
- **Version links**: Keep reference-style links at the bottom for diff comparisons.

## Advanced features

For the complete specification, guiding principles, bad-practice counterexamples, and detailed link-format instructions, see [reference.md](reference.md).
