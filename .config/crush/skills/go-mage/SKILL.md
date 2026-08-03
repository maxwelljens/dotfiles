---
name: go-mage
description: "Mage build tool — a Make-like build automation tool written in Go. Use when writing, modifying, or reviewing magefiles; setting up build/test/deploy automation in Go projects; converting Makefiles to Mage; debugging mage targets; or working with the mage CLI. Also triggers when code uses build tags 'mage', imports 'github.com/magefile/mage', or the user mentions mage, magefile, or magefile.org."
user-invocable: true
---

**Persona:** You are a Go build-engineer who automates with the same language the project is written in. You treat magefiles as first-class Go code — typed, testable, importable.

**Modes:**

- **Build** — creating magefiles from scratch: follow the file structure, build tag, package declaration, and target patterns sequentially.
- **Extend** — adding targets or namespaces to existing magefiles: read the current magefiles first, then apply changes consistent with the existing structure and conventions.
- **Debug** — a target is failing or behaving unexpectedly: reproduce the failure, instrument with `log` or `-v`, trace dependencies, and isolate the root cause.
- **Review** — auditing existing magefiles: check the Common Mistakes table, verify `mg.Deps` parallelism safety, confirm build tags, and validate error propagation.

# Mage — Build Automation in Go

Mage scans Go source files with `//go:build mage` in `package main` and turns exported functions into runnable targets. No Makefile syntax, no bash limitations — pure Go with full type safety, IDE support, and the ability to import any Go library.

## Magefile Structure

Two layout conventions, both valid:

```
# Flat: magefiles in project root (working directory = project root)
.
├── magefile.go           # targets here, or...
├── magefile_build.go     # ...split across multiple files
├── magefile_deploy.go
├── go.mod
└── go.sum

# Subdirectory: magefiles in subdirectory (working directory = project root)
.
├── magefiles/
│   ├── build.go          # package main, //go:build mage
│   ├── deploy.go
│   └── go.mod            # separate module (recommended)
├── go.mod
└── go.sum
```

When magefiles live in `magefiles/` (and no `magefile.go` exists in root), mage auto-discovers that directory as the source while keeping the project root as the working directory — equivalent to `mage -d magefiles -w .`.

## The Minimal Magefile

```go
//go:build mage

package main

import (
	"fmt"

	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Build compiles the project.
func Build() error {
	fmt.Println("building...")
	return sh.Run("go", "build", "./...")
}

// Test runs the test suite.
func Test() error {
	return sh.Run("go", "test", "-race", "./...")
}

// CI runs all checks needed before merge.
func CI() error {
	mg.Deps(Build, Test)
	fmt.Println("CI passed")
	return nil
}
```

### Build Tag

Every magefile MUST start with `//go:build mage`. This isolates mage code from the main build — the Go toolchain ignores it during normal compilation, and Mage only compiles files with this tag.

### Package

Magefiles MUST be `package main`. Mage compiles them into a temporary binary and executes the exported function matching the requested target name.

### go.mod

Magefiles need `github.com/magefile/mage` as a dependency. With the subdirectory layout, the magefiles directory should have its own `go.mod` — this is recommended because it keeps mage dependencies out of the main module graph.

## Targets

Targets are exported functions. mage matches function names case-insensitively on the command line.

### Basic Target

```go
// Build compiles the binary.
func Build() error {
	return sh.Run("go", "build", "-o", "app", "./cmd/app")
}
```

Run it: `mage build`

### Context-Aware Target

Accept `context.Context` as the first parameter for cancellation support:

```go
// Deploy builds and uploads artifacts.
func Deploy(ctx context.Context, env string) error {
	select {
	case <-ctx.Done():
		return ctx.Err()
	default:
	}
	return deployToEnv(ctx, env)
}
```

The context is cancelled on SIGINT, SIGTERM, or the `-t` timeout flag.

### Targets with Flags

Pointers to basic types become optional flags:

```go
// Release tags and pushes a release.
func Release(version string, dryRun *bool, force *bool) error {
	if *dryRun {
		fmt.Printf("would release version %s\n", version)
		return nil
	}
	// ... release logic
	return nil
}
```

Run it: `mage release v1.2.3 -dryrun -force`

Flag types supported: `*string`, `*bool`, `*int`, `*int64`, `*uint`, `*uint64`, `*float64`, `*time.Duration`.

### Help Text from Comments

Mage uses Go doc comments for automatic help:

```go
// Deploy runs the build and uploads artifacts to the server.
// It deploys to the given environment.
func Deploy(ctx context.Context, env string,
	version *string, // git tag for the build
	dryRun *bool,    // if true, outputs artifacts without uploading
) error {
	// ...
}
```

Shows in `mage -l` and `mage -h deploy`:

```
$ mage -l
Targets:
  deploy  runs the build and uploads artifacts to the server.

$ mage -h deploy
Deploy runs the build and uploads artifacts to the server.
It deploys to the given environment.

Usage:
    mage deploy <env> [<flags>]

Flags:
    -version=<string>  git tag for the build
    -dryrun=<bool>     if true, outputs artifacts without uploading
```

- First sentence of the comment → short description in `mage -l`
- Full comment → description in `mage -h <target>`
- Comment on parameter → flag description in help output

### Error Returns

Targets that return `error` signal failure; mage exits with status 1. A target can also return nothing — success is assumed if the function completes without panicking.

## Default Target

If no target is specified on the command line, mage runs the **zero-argument** target with the lowest line number — the first zero-argument function defined.

To make a specific target the explicit default, name it as the first target in the file, or lean on the natural file ordering.

## Dependencies

### Serial Dependencies

Call one target from another:

```go
func Test() error {
	return sh.Run("go", "test", "./...")
}

// Build runs tests first, then builds.
func Build() error {
	if err := Test(); err != nil {
		return err
	}
	return sh.Run("go", "build", "./...")
}
```

### Parallel Dependencies with mg.Deps

`mg.Deps` runs dependencies concurrently and only proceeds when all succeed:

```go
func CI() error {
	mg.Deps(
		mg.F(Lint, "strict"),      // call Lint("strict")
		Test,                        // call Test()
		func() error {              // inline anonymous dep
			return sh.Run("go", "vet", "./...")
		},
	)
	fmt.Println("all checks passed")
	return nil
}
```

The `mg.F` helper passes arguments to target functions. `mg.SerialDeps` is an alias for calling functions sequentially.

### Dependency Rules

- `mg.Deps` will not re-run a target that was already run in the current invocation — idempotent by design
- If any dependency returns an error, the parent target returns that error without running its body
- Dependencies run in goroutines — ensure concurrent safety (no shared mutable state without synchronization)

## Namespaces

Group related targets under a struct type. Embed `mg.Namespace` to opt into `mg.Deps` tracking:

```go
type Build mg.Namespace

// Linux cross-compiles for linux/amd64.
func (Build) Linux() error {
	return sh.RunWith(map[string]string{"GOOS": "linux", "GOARCH": "amd64"},
		"go", "build", "-o", "app-linux")
}

// Darwin cross-compiles for darwin/amd64.
func (Build) Darwin() error {
	return sh.RunWith(map[string]string{"GOOS": "darwin", "GOARCH": "amd64"},
		"go", "build", "-o", "app-darwin")
}

// All compiles for all target platforms.
func (Build) All() error {
	mg.Deps(mg.F(Build.Linux), mg.F(Build.Darwin))
	return nil
}
```

Run with: `mage build:linux`, `mage build:darwin`, `mage build:all`

Without embedding `mg.Namespace`, the struct is just a plain grouping — methods are still invocable but won't be tracked by `mg.Deps` for deduplication.

## The sh Package

`github.com/magefile/mage/sh` provides shell-like helpers:

```go
// Run a command, returning error on non-zero exit
sh.Run("go", "build", "./...")

// Run with custom environment
sh.RunWith(map[string]string{"GOOS": "linux"}, "go", "build")

// Run with custom working directory
sh.RunDir("/tmp", "ls", "-la")

// Capture stdout
out, err := sh.Output("git", "rev-parse", "--short", "HEAD")

// Capture stdout and stderr
combined, err := sh.CombinedOutput("some", "command")

// Run a command, discarding output
ok := sh.RunCmd("echo", "hello")
if ok {
	// succeeded
}

// Copy file
sh.Copy("src.txt", "dst.txt")

// Remove file (no error if missing)
sh.Rm("build/artifact")
```

## The mg Package

`github.com/magefile/mage/mg` provides dependency management and error helpers:

| Function | Purpose |
| --- | --- |
| `mg.Deps(fns ...interface{})` | Run dependencies in parallel, proceed only if all succeed |
| `mg.SerialDeps(fns ...interface{})` | Run dependencies sequentially |
| `mg.F(fn, args...)` | Call a target function with arguments |
| `mg.CtxDeps(ctx, fns ...interface{})` | Deps with context propagation |
| `mg.GoDeps(fns ...interface{})` | Deps that run in goroutines, errors collected |
| `mg.Verbose() bool` | Returns true when `-v` flag is set |

## Common Patterns

### Build + Test + Lint + CI

```go
//go:build mage

package main

import (
	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

func Build() error {
	return sh.Run("go", "build", "-o", "bin/app", "./cmd/app")
}

func Test() error {
	return sh.Run("go", "test", "-race", "-count=1", "./...")
}

func Lint() error {
	return sh.Run("golangci-lint", "run", "./...")
}

func CI() error {
	mg.Deps(Build, Test, Lint)
	return nil
}
```

### Cross-Compilation Namespace

```go
type Build mg.Namespace

var targets = map[string]struct{ goos, goarch string }{
	"linux-amd64":   {"linux", "amd64"},
	"linux-arm64":   {"linux", "arm64"},
	"darwin-amd64":  {"darwin", "amd64"},
	"darwin-arm64":  {"darwin", "arm64"},
	"windows-amd64": {"windows", "amd64"},
}

func (Build) All() error {
	for name := range targets {
		mg.Deps(mg.F(buildTarget, name))
	}
	return nil
}

func buildTarget(name string) error {
	t := targets[name]
	return sh.RunWith(map[string]string{"GOOS": t.goos, "GOARCH": t.goarch},
		"go", "build", "-o", fmt.Sprintf("bin/app-%s-%s", t.goos, t.goarch), "./cmd/app")
}
```

### Docker Build + Push Namespace

```go
type Docker mg.Namespace

func (Docker) Build(ctx context.Context) error {
	tag, _ := sh.Output("git", "describe", "--tags", "--always")
	return sh.Run("docker", "build", "-t", "myapp:"+tag, ".")
}

func (Docker) Push(ctx context.Context, tag string) error {
	return sh.Run("docker", "push", "myapp:"+tag)
}
```

### Version Injection

```go
var (
	version = "dev"
	commit  = "unknown"
)

// Version prints the build version.
func Version() {
	fmt.Printf("version: %s\ncommit: %s\n", version, commit)
}
```

And in CI: `go run mage.go -compile ./mage_out && ./mage_out version`

### Verbose Output Control

```go
func Build() error {
	if mg.Verbose() {
		fmt.Println("building with verbose output...")
	}
	return sh.Run("go", "build", "-v", "./...")
}
```

## Testing Magefiles

Test magefile logic by importing `sh` or `mg` in test files and calling targets directly — they are plain Go functions:

```go
//go:build mage

package main

import "testing"

func TestBuildTarget(t *testing.T) {
	// Call targets directly
	err := Build()
	if err != nil {
		t.Fatalf("Build() failed: %v", err)
	}
}
```

For CI, run magefile tests with: `go test -tags mage ./magefiles/`

## CLI Reference

```
mage [options] [target]

Commands:
  -clean         clean out old generated binaries from CACHE_DIR
  -compile <str> output a static binary to the given path
  -h             show help
  -init          create a starting template if no mage files exist
  -l             list mage targets in this directory
  -version       show version info

Options:
  -d <string>    directory to read magefiles from (default ".")
  -debug         turn on debug messages
  -f             force recreation of compiled magefile
  -keep          keep intermediate mage files after running
  -t <duration>  timeout (e.g. 5m30s)
  -v             show verbose output
  -w <string>    working directory where magefiles will run (default -d value)
```

### Typical Workflow

```bash
mage -init                    # scaffold starter magefile
mage -l                       # list available targets
mage -h build                 # show help for build target
mage build                    # run Build target
mage build:linux              # run namespaced target
mage -v deploy prod -dryrun   # run with verbose output and flags
mage -compile ./mage-bin      # compile magefiles into standalone binary
```

## Migrating from Make

| Make | Mage |
| --- | --- |
| `.PHONY: build` | exported `func Build()` |
| `build: test lint` | `mg.Deps(Test, Lint)` in `Build()` |
| `$(CC) $(CFLAGS)` | `sh.Run("gcc", cFlags...)` |
| `ifeq ... else ... endif` | `if` statements in Go |
| `$(shell cmd)` | `sh.Output("cmd")` |
| `.SILENT:` | `sh.RunCmd` (discard output) |
| `@echo ...` | `fmt.Println(...)` |

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Missing `//go:build mage` | Mage ignores files without the build tag. Add it as the first line |
| Wrong package declaration | Magefiles MUST be `package main`. Check the package line |
| File named `magefile.go` in root with `magefiles/` dir also present | Root file takes precedence; the `magefiles/` directory is ignored |
| Calling `mg.Deps(Test, Lint)` and both write to the same file | Deps run in parallel — use `mg.SerialDeps` or synchronize |
| Using `os.Exit` instead of returning `error` | Return the error so callers can handle it; `os.Exit` kills the process before cleanup |
| Not returning errors from `sh.Run` | `sh.Run` returns `error` on non-zero exit — propagate it |
| Importing mage packages without a `go.mod` in the magefiles directory | Add `go.mod` with `go mod init` and `go get github.com/magefile/mage` |
| Embedding `mg.Namespace` but never using `mg.Deps` | The embedding is optional — only embed when you need deduplication via `mg.Deps` |
| Using `mage` to compile magefiles inside a `Dockerfile` | Use `mage -compile` to produce a standalone binary, then run that binary instead |
| Passing `*string` flag but dereferencing without nil check | Flags default to nil — guard with `if version == nil { ... }` |

## Related Skills

See `go-cli`, `go-testing`, and `go-project-layout` skills.
