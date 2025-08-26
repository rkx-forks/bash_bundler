# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

bash_bundler (Simple Bash Bundler) is a Go command-line tool that bundles multiple bash scripts into a single, self-contained script by recursively inlining all `source` commands. The tool processes bash scripts, follows source references, and creates a single executable that contains all dependencies.

## Common Commands

### Build and Development
```bash
# Build the binary
go build -o bash_bundler

# Run tests
make test
# or
go test ./pkg/bundler/ -v

# Run linter
make lint
# or
go run github.com/golangci/golangci-lint/cmd/golangci-lint run ./...

# Run a single test
go test -v -run TestBundleFile ./pkg/bundler/

# Build and run immediately
go run main.go bundle -e input.sh -o output.sh
```

### Usage Examples
```bash
# Bundle a bash script
./bash_bundler bundle -e script.sh -o bundled.sh

# Bundle with minification
./bash_bundler bundle -e script.sh -o bundled.sh -m

# Show help
./bash_bundler help
```

## Architecture

### Package Structure
- `main.go`: CLI entry point using commando library for command parsing
- `pkg/bundler/`: Core bundling logic
  - `bundler.go`: Main bundler implementation with `BundleFile()` function
  - `bundler_test.go`: Unit tests for bundling functionality
  - `testdata/`: Test fixtures for various bundling scenarios
- `pkg/log/`: Logging utilities using sigs.k8s.io/controller-runtime

### Key Components

1. **Bundler Core (`pkg/bundler/bundler.go`)**
   - `BundleFile()`: Main entry point that orchestrates the bundling process
   - `bundleRecursively()`: Recursively processes files and inlines sources
   - `handleSourceCommand()`: Processes individual source commands
   - Uses `mvdan.cc/sh/v3` for bash syntax parsing and manipulation

2. **Source Command Detection**
   - Handles regular source: `source file.sh` or `. file.sh`
   - Handles embedded source: `VAR=$(source file.sh)`
   - Properly resolves relative paths based on the current file's directory

3. **Output Format**
   - Adds timestamp headers: `# --- Bundled on <date> ---`
   - File markers: `# --- Start of <filepath> ---` and `# --- End of <filepath> ---`
   - Preserves original formatting unless minify flag is used

### Testing Strategy
- Unit tests in `pkg/bundler/bundler_test.go` cover:
  - Basic bundling functionality
  - Nested source handling
  - Relative path resolution
  - Embedded source syntax
  - Error conditions (circular dependencies, missing files)
- Test fixtures in `testdata/` provide realistic test scenarios

### Important Implementation Details
- The bundler maintains a map of already processed files to avoid infinite loops
- Path resolution always happens relative to the file being processed, not the working directory
- The minification feature uses the sh library's printer with `Minify: true`
- Logging is done through the controller-runtime log framework