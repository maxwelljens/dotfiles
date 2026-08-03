```.goreleaser.yaml
version: 2

builds:
  - binary: <NAME>
    env:
      - CGO_ENABLED=0
    ldflags:
      - -s -w -X main.buildDate={{.Date}} -X main.version={{.Version}}
    goos:
      - linux
      - windows
      - darwin
    goarch:
      - arm64
      - amd64
      - "386"
    dir: cmd

archives:
  - formats: [tar.gz]
    # this name template makes the OS and Arch compatible with the results of `uname`.
    name_template: >-
      {{ .ProjectName }}_
      {{- title .Os }}_
      {{- if eq .Arch "amd64" }}x86_64
      {{- else if eq .Arch "386" }}i386
      {{- else }}{{ .Arch }}{{ end }}
      {{- if .Arm }}v{{ .Arm }}{{ end }}
    # use zip for windows archives
    format_overrides:
      - goos: windows
        formats: [zip]

changelog:
  sort: asc
  filters:
    exclude:
      - "^docs:"
      - "^test:"

upx:
  - # Templates: allowed.
    enabled: true

    # Filter by build ID.
    ids: [build1, build2]

    # Filter by GOOS.
    goos: [linux, darwin]

    # Filter by GOARCH.
    goarch: [arm, amd64]

    # Filter by GOARM.
    goarm: [8]

    # Filter by GOAMD64.
    goamd64: [v1]

    # Compress argument.
    # Valid options are from '1' (faster) to '9' (better), and 'best'.
    compress: best

    # Whether to try LZMA (slower).
    lzma: true

    # Whether to try all methods and filters (slow).
    brute: true
```

---

```.golangci.yaml
version: "2"

linters:
  enable:
    - errcheck # checking for unchecked errors, these unchecked errors can be critical bugs in some cases
    - govet # reports suspicious constructs, such as Printf calls whose arguments do not align with the format string
    - usetesting # reports uses of functions with replacement inside the testing package
    - perfsprint # checks that fmt.Sprintf can be replaced with a faster alternative
    - unused # checks for unused constants, variables, functions and types
    - gocritic # provides diagnostics that check for bugs, performance and style issues
    - staticcheck # is a go vet on steroids, applying a ton of static analysis checks
    - godoclint # checks Golang's documentation practice
    - errorlint # finds code that will cause problems with the error wrapping scheme introduced in Go 1.13
    - recvcheck # checks for receiver type consistency
    - unparam # reports unused function parameters
    - usestdlibvars # detects the possibility to use variables/constants from the Go standard library
```
