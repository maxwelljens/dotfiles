---
name: scoped-commit
description: Write and validate commit messages following the Scoped Commits format (scopedcommits.com). Use when a user asks to commit changes, about commit format, or to update changes.
---

# Scoped Commits

## Quick start

A properly formatted commit message has this **minimum** structure:

```
<scope>: <description>

[optional body]

[optional trailer(s)]
```

A real example:

```
auth: fix login bug when session expires mid-request

The session token was not refreshed before the middleware
ran, causing intermittent 401s on long-lived connections.

Fixes #42
```

## Workflows

### 1. Writing a new commit message

Follow the checklist:

- [ ] Start with a **scope**: the subsystem, area, or module the commit touches (e.g., `auth`, `net/http`, `cli`, `docs`).
- [ ] Follow the scope with a colon and a single space, then the **description**.
- [ ] Write a **short description** in imperative mood (`add`, not `adds` or `added`), concise enough to fit on one line.
- [ ] If the change needs explanation, add a **body** after a blank line.
- [ ] Add **trailer(s)** (e.g., `Fixes #42`, `Reviewed-by: Alice`) after another blank line.
- [ ] Do NOT use a type prefix like `feat:` or `fix:`. The scope is the subject of the change, not its kind.

### 2. Choosing a scope

- Use the **most specific** scope that identifies the area touched: a package, module, directory, or subsystem (`i2c`, `net/http/cookiejar`, `xwayland`).
- Use a path-like scope for nested areas (`net/http/cookiejar`) or a short name for broad areas (`auth`, `cli`).
- If a commit covers **multiple scopes**:
  - Use a more general scope that encompasses them, OR
  - List both, comma-separated (`auth, api:`), OR
  - Use `treewide`, `all`, or `global` if the entire tree is touched.
- If no scope fits, treat it as a "special commit" and just write a good description.
- **Reverts, merges, and other special commits** may be formatted however you like (default Git revert format is fine).

### 3. Including a ticket number

Put the ticket reference where it is most useful:

- In parentheses after the scope:
  ```
  auth (PROJ-123): fix login bug
  ```
- Or in the body/trailer:
  ```
  auth: fix login bug

  Fixes the race when refreshing expired sessions.

  Jira-Ticket: PROJ-123
  ```

### 4. Multi-line bodies and trailers

- Separate **header** from **body** with a blank line.
- Separate **body** from **trailer(s)** with a blank line.
- Trailer format: `token: value` (e.g., `Fixes #12`, `Reviewed-by: Alice`, `Jira-Ticket: PROJ-123`).
- Wrap body lines at ~72 characters.

### 5. Squashing PR commits

When squash-merging a PR, use the PR title as the scoped commit header and combine body/trailer info into the squashed commit message.

## What NOT to do

- Do **not** use Conventional Commit type prefixes (`feat:`, `fix:`, `chore:`). Scope describes *where*, not *what kind*.
- Do **not** generate changelogs from the commit log. Commit logs are for contributors; changelogs are for users. If the user wants a changelog, point them to the `keep-a-changelog` approach and maintain it manually.
- Do not make the scope a verb or a change-kind word; it must name an area of the codebase.

## Validation

When reviewing or validating a commit message:

- [ ] Header matches `<scope>: <description>` (except special commits like reverts/merges).
- [ ] Scope names a real subsystem/area of the project (check the directory tree if unsure).
- [ ] Description is imperative, present tense, no trailing period.
- [ ] Blank line between header, body, and trailers.
- [ ] No Conventional Commit type prefixes.
- [ ] Ticket references are present if the project requires them.
