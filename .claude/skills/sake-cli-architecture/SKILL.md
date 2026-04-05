---
name: sake-cli-architecture
description: Use when working on SakeCLI or SakeCLILibrary targets — CLI entry point, config resolution, SakeAppManager build/run lifecycle, error handling, shell execution.
---

# Sake CLI Architecture

Reference for the CLI side of Sake (the `sake` binary users install).

## Module Split

```
SakeCLI          → Thin executable. @main struct, ArgumentParser commands.
SakeCLILibrary   → All logic. Testable. Config, SakeAppManager, shell execution.
SakeShared       → Types shared between CLI and Sake library.
```

SakeCLI was split from SakeCLILibrary specifically for testability (`SakeCLILibraryTests`).

## CLI Entry Point

```swift
// Sources/SakeCLI/SakeCLI.swift
@main struct SakeCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sake",
        subcommands: [InitCommand, CleanCommand, BuildCommand, RunCommand, ListCommand] + platformSpecific,
        defaultSubcommand: RunCommand.self,  // `sake myCommand` == `sake run myCommand`
    )
}
```

Platform-specific: `EditCommand` only on macOS.

## CLI Commands

| Command | Does |
|---------|------|
| `init` | Creates SakeApp/ from template (UninitializedMode → InitializedMode) |
| `build` | Compiles SakeApp, `--show-bin-path` to print binary path |
| `clean` | Removes SakeApp build artifacts |
| `run` | Builds if needed → executes command in SakeApp binary |
| `list` | Builds if needed → lists commands (human-readable or `--json`) |
| `edit` | Opens SakeApp in Xcode (macOS only) |

## SakeAppManager — Phantom Types

```swift
package enum UninitializedMode {}
package enum InitializedMode {}
package struct SakeAppManager<Mode>: ~Copyable { ... }
```

- `makeInUninitializedMode(sakeAppPath:)` — for `init` command
- `makeInInitializedMode(sakeAppPath:)` — validates SakeApp exists, for all other commands
- `initializeProject()` consumes UninitializedMode, returns InitializedMode

## Build Lifecycle (InitializedMode)

1. `validateProject()` — checks Package.swift exists, dumps it, verifies SakeApp executable product
2. `buildExecutableIfNeeded()` — compares executable mtime vs source files, checks Swift version changes
3. `buildExecutable()` — `swift build`, touches executable, saves Swift version
4. Binary cached at `SakeApp/.build/debug/SakeApp`

Prebuilt binary path: skips build entirely, used in CI.

## How CLI Runs a Command

```
sake myCommand arg1 arg2
  → RunCommand parses: command="myCommand", args=["arg1","arg2"]
  → ConfigManager resolves config (CLI > ENV > .sake.yml)
  → SakeAppManager builds SakeApp if needed
  → Executes: SakeApp run --case-converting-strategy X myCommand arg1 arg2
  → SakeApp binary (Sake library) handles actual command execution
```

## Config System

See `sake-config-system` skill for details. Key types:
- `CommonOptions` — `--config-path`, `--sake-app-path`
- `CommandRelatedCommonOptions` — `--sake-app-prebuilt-binary-path`, `--case-converting-strategy`
- `CLIConfig`, `ENVConfig`, `FileConfig` → `ConfigResolver` → `Config`

## Error Handling

Two layers:

**SakeAppManagerError** (CLI level):
- `sakeAppNotInitialized`, `sakeAppAlreadyInitialized`
- `sakeAppNotValid(ValidationError)` — Package.swift issues
- `failedToBuildSakeApp`, `failedToReadSwiftVersion`
- `sakeAppError(.businessError | .unexpectedError)` — wraps SakeApp exit codes

**SakeAppError** (Sake library level, inside SakeApp binary):
- `commandNotFound` — with closest match suggestions (Levenshtein distance ≤ 2)
- `commandRunFailed`, `commandDuplicate`, `commandArgumentsParsingFailed`
- All conform to `LocalizedError`

Exit codes: `SakeAppExitCode` (101-105) in SakeShared.

## Shell Execution

`ShellExecutor` wraps swift-subprocess. `SakeAppManagerCommandExecutor` protocol abstracts shell calls for testing:
- `packageDump()`, `packageClean()`, `buildExecutable()`
- `callRunCommandOnExecutable(...)`, `callListCommandOnExecutable(...)`
- `swiftVersionDump()`, `packageShowBinPath()`

## Key Files

```
Sources/SakeCLI/SakeCLI.swift                              — entry point
Sources/SakeCLI/RunCommand.swift                           — default subcommand
Sources/SakeCLILibrary/SakeAppManager/SakeAppManager.swift — phantom type factory
Sources/SakeCLILibrary/SakeAppManager/SakeAppManager+InitializedMode.swift — build/run logic
Sources/SakeCLILibrary/Config/ConfigManager.swift          — config resolution
Sources/SakeCLILibrary/SakeAppManager/SakeAppManagerError.swift — error types
```
