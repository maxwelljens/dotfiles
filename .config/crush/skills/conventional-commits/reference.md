# Conventional Commits — Full Reference

Based on [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) and community best practices.

## Specification (BNF-ish)

```
<commit message>      ::= <header><body?><footer?>
<header>              ::= <type>("("<scope>")")?"!": <description>
<type>                ::= feat | fix | docs | style | refactor | perf | test | build | ci | chore | revert | ... (any string)
<scope>               ::= any string (recommended: noun, lowercase)
<description>         ::= short summary in imperative mood, first word lowercase
<body>                ::= <blank line> <text>
<footer>              ::= <blank line> <token>" " <separator>" " <value>
<separator>           ::= ": " | " #"
<token>               ::= BREAKING CHANGE | Reviewed-by | Closes | See-also | ... (any custom token)
```

- The `!` before the colon denotes a breaking change.
- `BREAKING CHANGE` is a special token; it must be in all caps and be the first token of a footer line (can be followed by a description).

## Detailed Rules

1. **Type** is required and must be lowercase. While the spec allows any string, tools expect `feat` and `fix` for changelog generation (MINOR and PATCH bumps). Other types are ignored for versioning but still useful for human readers.
2. **Scope** is optional but must be placed in parentheses immediately after the type. No spaces inside the parentheses.
3. **Description** must immediately follow the colon and space. It should be a short, imperative sentence (e.g., `add user login`, not `Added user login`).
4. **Breaking changes** are indicated by an `!` before the colon, or by a `BREAKING CHANGE` footer (or both). The footer variant allows a longer, multi-line explanation.
5. **Body** can include any text, but it’s good practice to explain *what* and *why*, not *how*.
6. **Footers** each require a blank line before them. Multiple footers are placed consecutively; no blank line between them.

## Examples

### Simple fix
```
fix: prevent racing condition in request handler
```

### Feature with scope
```
feat(lang): add Spanish translation
```

### Breaking change using `!`
```
refactor(runtime)!: drop Node.js 14 support
```

### Breaking change using footer
```
feat(api): migrate endpoint to GraphQL

BREAKING CHANGE: The REST endpoint at /users has been removed; use /graphql with query `users` instead.
```

### Commit with body and multiple footers
```
fix(db): resolve connection timeout on startup

The connection pool was not being initialized before the first query,
which sometimes caused timeouts if the database was slow to start.

Closes #312
Reviewed-by: Alice
```

### Revert commit

```
revert: feat(payment): add Stripe integration

This reverts commit 667ecc1654a317a13331b17617d973392f415f02.

The Stripe service caused unexpected charges in test mode.
```

## Common Extension Types

Beyond the core `feat`/`fix`, many teams adopt these for consistency:

| Type       | Purpose                                              |
|------------|------------------------------------------------------|
| `style`    | Code formatting, indentation, whitespace changes     |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf`     | Code change that improves performance                |
| `test`     | Adding missing tests or correcting existing tests    |
| `docs`     | Documentation only changes                          |
| `build`    | External dependency or build tool changes            |
| `ci`       | CI configuration and scripts                         |
| `chore`    | Grunt tasks, package updates, no production code change |
| `revert`   | Reverts a previous commit                            |

## Why Conventional Commits?

- Automatically determine SemVer bumps (fix=patch, feat=minor, breaking=major).
- Generate changelogs automatically (esp. when combined with `keep-a-changelog`).
- Communicate the nature of changes clearly to contributors.
- Trigger CI/CD pipelines (e.g., deployment, testing) based on commit types.
- Make commit history navigable and grep-friendly.

## Tooling

- **commitlint**: Validate commit messages automatically (config `@commitlint/config-conventional`).
- **commitizen**: Interactive prompt to build conventional commits.
- **standard-version** / **semantic-release**: Automate versioning, changelog generation, and release.

These tools expect exact formatting: lowercase types, no capitals in type/scope, and a colon-space separator.

## Combining with Keep a Changelog

The ultimate combination:

1. Write commits in Conventional Commits style.
2. Use `semantic-release` or `standard-version` to generate a `CHANGELOG.md` that conforms to Keep a Changelog.
3. Publish the changelog alongside your release.

## Bad Practices to Avoid

- **Mixing voice**: Use imperative in the description, not indicative. `add feature` not `adds feature` or `added feature`.
- **Capital first letter in description**: `fix: handle null` not `fix: Handle null`.
- **Using imprecise types**: Don't use `fix` for a feature or `feat` for a refactor. If in doubt, choose the most specific type that conveys the intent.
- **Skipping breaking change notation**: Always mark breaking changes, even if they seem "small."
- **Putting a period at the end of the description**: Some linters consider it correct without a period (though not strictly forbidden).
- **Using markdown in the header**: Keep headers plain text.

## Quick Reference Card

```
<type>(<scope>): <short summary>
^--^  ^---^    ^----------^
|     |        |
|     |        Must be imperative, lowercase, no period.
|     Optional, lowercase, no spaces.
Must be lowercase, specific.
```

Mark breaking changes with `!` after scope (or footer `BREAKING CHANGE:`).
