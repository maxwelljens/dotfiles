---
name: go-init
description: Initialise a new Go project with standard tooling using cobra CLI, goreleaser cross-platform builds, golangci-lint static checks, and bun for JavaScript frontends. Use when starting a new Go project, setting up a Go service, or scaffolding a repository.
---

# Go Project Initialization

## Quick start

```bash
go mod init <module>
mkdir -p cmd internal
touch cmd/main.go internal/.gitkeep
# Copy the configs below
cp reference.md/.goreleaser.yaml ./
cp reference.md/.golangci.yml ./
```

## Workflows

### 1. CLI setup with Cobra

Refer to the `go-cli` skill for full POSIX-compliant CLI scaffolding.
At minimum, create `cmd/root.go` with a `cobra` root command and integrate
`version`, `buildDate` flags. Use `--config` for config file support.

### 2. Goreleaser for multiplatform builds

Copy [.goreleaser.yaml](#goreleaser-config) (in `reference.md`) to the project
root. The config:

- Builds `GOOS=linux,darwin,windows` and `GOARCH=amd64,arm64` (plus 386)
- Strips debug info via `-s -w`
- Injects version/date via `-X main.version` and `-X main.buildDate`
- Compresses binaries with `upx` (requires `upx` to be installed on system)
- Generates `.tar.gz` (Linux/Darwin) and `.zip` (Windows) archives

Run `goreleaser release --snapshot --clean` to create the binaries.

### 3. golangci-lint static checks

Copy [.golangci.yml](#golangci-lint-config) to the project root.
Enabled linters (beyond `gopls`): `errcheck`, `govet`, `staticcheck`, `unused`,
`godoclint`, `errorlint`, `recvcheck`, `unparam`, `usestdlibvars`, `gocritic`,
`perfsprint`, `usetesting`. Adjust `run.skip-dirs` if needed.

More information can be found online at [https://golangci-lint.run/docs/].

Run `golangci-lint run ./...`.

### 4. Frontend with Bun

If there are any JavaScript/TypeScript assets, embed them in the Go binary
using `bun`:

```bash
bun init
bun add react react-dom ...  # as needed
bun build --outdir=dist
```

Embed with `//go:embed dist/*` in your Go code.

## Advanced features

See [reference.md](reference.md) for the full config files and explanations of
Go Releaser and linter choices. For more information on setting up CLI, inspect
the see the `go-cli` skill.

## Checklist

- [ ] `go mod init` and `cmd/` directory structure
- [ ] Cobra root command with `--version`, `--config`
- [ ] `.goreleaser.yaml` present and working
- [ ] `.golangci.yml` present, `golangci-lint` run without errors
- [ ] If frontend: `bun init`/`bun build` + Go embed setup
- [ ] CI workflow (e.g., GitHub Actions) runs lint + goreleaser snapshot
