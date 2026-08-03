---
name: conventional-commits
description: Write and validate commit messages following the Conventional Commits v1.0.0 specification and best practices. Use when a user asks to commit changes, about commit format, or to update changes.
---

# Conventional Commits

## Quick start

A properly formatted commit message has this **minimum** structure:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

A real example:

```
feat(auth): add OAuth2 login support

Implements the authorization code flow with PKCE,
allowing users to log in via Google and GitHub.

Closes #42
```

## Workflows

### 1. Writing a new commit message

Follow the checklist:

- [ ] Start with a **type** from the standard list (see below).
- [ ] Add an optional **scope** in parentheses if the change affects a specific subsystem.
- [ ] Write a **short description** in lowercase imperative mood (`add`, not `adds` or `added`).
- [ ] If the change introduces a **breaking change**, add `!` immediately before the colon OR put `BREAKING CHANGE:` in the footer.
- [ ] If a ticket/issue is closed, add a `Closes #NN` footer.
- [ ] If additional explanation is needed, add a blank line then the body.

### 2. Choosing a type

Use the **most specific** type that applies. Common types (not exhaustive):

| Type       | When to use                                                       |
|------------|-------------------------------------------------------------------|
| `feat`     | A new feature (corresponds to MINOR in SemVer)                    |
| `fix`      | A bug fix (PATCH)                                                 |
| `docs`     | Documentation only changes                                        |
| `style`    | Formatting, missing semi-colons, etc. (no code change)            |
| `refactor` | Code restructuring without fixing a bug or adding a feature       |
| `perf`     | Performance improvement                                           |
| `test`     | Adding or correcting tests                                        |
| `build`    | Changes to build system or external dependencies                  |
| `ci`       | Changes to CI configuration files and scripts                     |
| `chore`    | Other changes that don't modify src or test files                 |
| `revert`   | Reverts a previous commit (header becomes `revert: <old header>`) |

### 3. Marking a breaking change

Either:

- Add `!` after the type/scope:
  `feat(api)!: drop support for legacy v1 endpoints`
- Or add a footer with `BREAKING CHANGE: description`:
  ```text
  feat(api): drop support for legacy v1 endpoints

  BREAKING CHANGE: API v1 is no longer supported. Migrate to v2.
  ```

Use the `!` method for discoverability; the footer method for longer explanations.

### 4. Multi-line bodies and footers

- Separate **header** from **body** with a blank line.
- Separate **body** from **footer** with a blank line.
- Footer format: `token: value` or `token #value` (e.g., `Closes #12`, `BREAKING CHANGE: ...`, `Reviewed-by: Alice`).

### 5. Squashing PR commits

When squash-merging a PR, often a single conventional commit is preferred. Use the PR title as the commit header, and combine all body/footer info into the squashed commit message.

## Advanced features

- The full specification with BNF grammar, real-world edge cases, and tooling setup is in [reference.md](reference.md).
- For automating changelog generation from these commits, combine with the `keep-a-changelog` skill.

---

Checklist before submitting:

- [ ] Type is lowercase, correct, and specific.
- [ ] Scope is parenthesized and lowercase (if used).
- [ ] Description is imperative, present tense.
- [ ] Breaking changes are communicated with `!` or `BREAKING CHANGE` footer.
- [ ] Body is separated by blank lines.
