---
name: go-init
description: Initialise a new Go project with standard tooling using cobra CLI, goreleaser cross-platform builds, golangci-lint static checks, and deno for JavaScript frontends. Use when starting a new Go project, setting up a Go service, or scaffolding a repository.
user-invocable: true
---

# Go Project Initialization

## Quick start

```bash
go mod init <module>
mkdir -p cmd/myapp internal
touch cmd/myapp/main.go internal/.gitkeep
```

Set the module path to the repository URL
(`go mod init github.com/you/myapp`), then copy the two config templates out of
this skill's `references/` directory into the project root (steps 2 and 3).

One directory per binary under `cmd/`: `cmd/myapp/main.go`. A bare
`cmd/main.go` is wrong, it builds a binary called `cmd` and collides as soon as
a second entry point (`cmd/migrate/`) appears.

## Workflows

### 1. CLI setup with Cobra

Refer to the `go-cli` skill for full POSIX-compliant CLI scaffolding.
At minimum, create `cmd/myapp/root.go` with a `cobra` root command and integrate
`version`, `buildDate` flags. Use `--config` for config file support.

### 2. Goreleaser for multiplatform builds

Copy [references/goreleaser.yaml](references/goreleaser.yaml) to
`.goreleaser.yaml` in the project root. The config:

- Builds `GOOS=linux,darwin,windows` and `GOARCH=amd64,arm64` (plus 386)
- Strips debug info via `-s -w`
- Injects version/date via `-X main.version` and `-X main.buildDate`
- Compresses binaries with `upx` (requires `upx` to be installed on system)
- Generates `.tar.gz` (Linux/Darwin) and `.zip` (Windows) archives

Replace the `<NAME>` placeholder with the binary name, and adjust `binary:`,
`dir:` and `main:` to match the entry point you actually have under `cmd/`.

Run `goreleaser release --snapshot --clean` to create the binaries.

### 3. golangci-lint static checks

Copy [references/golangci.yaml](references/golangci.yaml) to `.golangci.yml` in
the project root.
Enabled linters (beyond `gopls`): `errcheck`, `govet`, `staticcheck`, `unused`,
`godoclint`, `errorlint`, `recvcheck`, `unparam`, `usestdlibvars`, `gocritic`,
`perfsprint`, `usetesting`. Adjust `run.skip-dirs` if needed.

More information can be found online at [https://golangci-lint.run/docs/].

Run `golangci-lint run ./...`.

### 4. Frontend with Deno

If there are any JavaScript/TypeScript assets, embed them in the Go binary
using `deno`:

```bash
deno init
deno add npm:react npm:react-dom npm:@types/react   # as needed
deno bundle --platform=browser --minify --outdir=dist main.tsx
```

Set `"compilerOptions": { "jsx": "react-jsx", "jsxImportSource": "react" }` in
`deno.json` before bundling a `.tsx` entry point; the automatic runtime is the
recommended setup, and `@types/react` is what gives JSX type checking.

Embed with `//go:embed dist/*` in your Go code.

`deno bundle` is an experimental subcommand and is not a replacement for a real
asset pipeline. When the frontend needs a dev server, HMR, hashed filenames or
code splitting, scaffold with `deno init --npm vite`, keep Vite as the bundler,
and run it through a `deno.json` task (`deno task build`) so the build still
emits `dist/` for `//go:embed`.

### 5. Build automation and command running

Two tools, different jobs, both optional:

- **just** — command runner. The everyday typing surface (`just test`,
  `just lint`, `just build`), including commands that install built binaries.
- **Magefile** — build and install automation written in Go. Reach for it when
  the steps need real Go: cross-compiled artifacts, code generation, packaging,
  CI-invoked builds. See the `go-mage` skill.

They do not conflict: `just` runs commands, a Magefile produces artifacts.

## Advanced features

See [references/goreleaser.yaml](references/goreleaser.yaml) and
[references/golangci.yaml](references/golangci.yaml) for the full config files
and inline explanations of the Go Releaser and linter choices. For more
information on setting up CLI, see the `go-cli` skill.

## Checklist

- [ ] `go mod init` with one directory per binary under `cmd/`
- [ ] Cobra root command with `--version`, `--config`
- [ ] `.goreleaser.yaml` present and working
- [ ] `.golangci.yml` present, `golangci-lint` run without errors
- [ ] If frontend: `deno init`, deps added, `dist/` built and embedded
- [ ] `just` recipes and/or a Magefile, depending on what the project automates
- [ ] CI workflow (e.g., GitHub Actions) runs lint + goreleaser snapshot
