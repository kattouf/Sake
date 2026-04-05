---
name: sake-command-patterns
description: Use when writing or modifying Sake commands, CommandGroups, SakeApp files, or SakeApp/ directory code. Covers Command struct, dependencies, skipIf, context, storage, subprocess patterns, argument parsing.
---

# Sake Command Patterns

Reference for writing commands in the Sake framework.

## Command Struct

`Command` is a Sendable struct with async/throws closures:

```swift
public struct Command: Sendable {
    let description: String?
    let dependencies: [Command]
    let runDependenciesConcurrently: Bool
    let skipIf: @Sendable (Context) async throws -> Bool  // default: { _ in false }
    let run: @Sendable (Context) async throws -> Void     // default: { _ in }
}
```

## Visibility Rules

Only `public static var` of type `Command` or `Sake.Command` are exposed to CLI. Non-public or non-static commands work as internal dependencies but aren't callable from terminal. Typealiases don't work.

```swift
public static var build: Command { ... }  // visible in CLI
static var cleanIfNeeded: Command { ... } // internal, usable as dependency
```

## CommandGroup & @CommandGroup Macro

```swift
@CommandGroup
struct BuildCommands {
    public static var build: Command { ... }
}
```

Macro generates `CommandGroup` conformance with `commands: [String: Command]` dict. Register groups in main struct:

```swift
@main @CommandGroup
struct Commands: SakeApp {
    static var configuration: SakeAppConfiguration {
        SakeAppConfiguration(commandGroups: [BuildCommands.self, TestCommands.self])
    }
    public static var lint: Command { ... } // root-level commands also work
}
```

## Dependencies

```swift
// Sequential (default)
Command(dependencies: [clean, fetch], run: { _ in ... })

// Concurrent
Command(dependencies: [a, b, c], runDependenciesConcurrently: true, run: { _ in ... })

// Direct run via CommandRunner
Command(run: { context in
    try await CommandRunner(command: otherCommand, context: context).run()
})
```

## Conditional Execution (skipIf)

```swift
Command(
    skipIf: { context in
        let args = try TestArguments.parse(context.arguments)
        return args.skipBuild
    },
    run: { _ in ... }
)
```

When skipIf returns true, the command AND its dependencies are skipped entirely.

## Context

Properties: `arguments: [String]`, `environment: [String: String]`, `appDirectory: String`, `runDirectory: String`, `storage: Storage`, `interruptionHandler: InterruptionHandler`.

### Context Extensions

```swift
extension Command.Context {
    var projectRoot: String { "\(appDirectory)/.." }
}
```

### Sharing Data via Storage

Thread-safe key-value store (NSRecursiveLock). Shared across command dependency chain:

```swift
// In dependency
context.storage["build-output"] = outputPath
// In main command
let path = context.storage["build-output"] as? String
```

### Context Mapping for Dependencies

```swift
dependencies: [
    buildTests,
    unitTests.mapArguments { $0 + ["--skip-build"] },
    deploy.mapEnvironment { env in
        var e = env; e["TARGET"] = "prod"; return e
    },
]
```

## Argument Parsing

Use ArgumentParser `ParsableArguments` inside commands:

```swift
Command(run: { context in
    struct Args: ParsableArguments {
        @Flag(name: .long) var clean: Bool = false
        @Flag(name: .long) var skipBuild: Bool = false
    }
    let args = try Args.parse(context.arguments)
    ...
})
```

## Subprocess Execution

Project uses helper functions wrapping swift-subprocess (see `SakeApp/SubprocessPresets.swift`):

```swift
// Print output to stdout/stderr
try await runAndPrint("swift", "build", "--build-tests")

// Capture output
let result = try await run("mise", "which", "swiftformat")
if result.terminationStatus.isSuccess { ... }
```

## Interruption Handling

```swift
Command(run: { context in
    context.interruptionHandler.register {
        print("Cleanup on Ctrl+C...")
    }
    // long-running work
})
```

## Common Pattern: Ensure Tool Installed

```swift
static var ensureSwiftFormatInstalled: Command {
    Command(
        description: "Ensure swiftformat is installed",
        skipIf: { _ in
            try await run("mise", "which", "swiftformat").terminationStatus.isSuccess
        },
        run: { _ in
            try await runAndPrint("mise", "install", "swiftformat")
        },
    )
}
```
