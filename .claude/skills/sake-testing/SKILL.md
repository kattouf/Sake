---
name: sake-testing
description: Use when writing or running tests for the Sake project — unit tests, macro expansion tests, integration tests, test helpers, and CI test commands.
---

# Sake Testing Patterns

## Test Targets

| Target | Tests | Framework |
|--------|-------|-----------|
| `SakeTests` | Command, CommandRunner, CommandsPreprocessor, ClosestMatchFinder, CommandListFormatter | XCTest |
| `SakeCLILibraryTests` | ConfigManager, ConfigResolver, SakeAppManager, FileHandle | XCTest |
| `SakeMacrosTests` | @CommandGroup macro expansion | XCTest + SwiftSyntaxMacrosTestSupport |
| `IntegrationTests` | Full CLI execution via subprocess | XCTest + swift-subprocess |

## Running Tests

```bash
sake test                          # build + unit + integration
sake build_tests                   # build only
sake unit_tests --skip-build       # unit tests without rebuild
sake integration_tests --skip-build # integration tests without rebuild
```

Direct swift commands:
```bash
swift test --filter "^(?!.*\bIntegrationTests\b).*"  # unit + macro tests
swift test --filter IntegrationTests                   # integration only
swift test                                              # everything
```

## Unit Test Patterns

### Command Execution Tracking

```swift
nonisolated(unsafe) var runnedCommands: [String] = []

let command = Command(
    skipIf: { _ in runnedCommands.append("skipIf"); return false },
    run: { _ in runnedCommands.append("run") },
)

let runner = CommandRunner(command: command, context: .empty)
try await runner.run()
XCTAssertEqual(runnedCommands, ["skipIf", "run"])
```

### Empty Context Helper

```swift
private extension Command.Context {
    static var empty: Command.Context {
        Command.Context(
            arguments: [],
            environment: [:],
            appDirectory: "",
            runDirectory: "",
            storage: .init(),
            interruptionHandler: .init(processMonitor: .init()),
        )
    }
}
```

### Storage Sharing Tests

```swift
let dep = Command(run: { context in
    context.storage["key"] = "value"
})
let main = Command(dependencies: [dep], run: { context in
    XCTAssertEqual(context.storage["key"] as? String, "value")
})
```

## Macro Expansion Tests

```swift
import SakeMacros
import SwiftSyntaxMacrosTestSupport

assertMacroExpansion(
    inputSource,
    expandedSource: expectedOutput,
    macros: ["CommandGroup": CommandGroupMacro.self],
)
```

## CLI Library Tests

Use protocol-based mocking for `SakeAppManagerFileHandle` and `SakeAppManagerCommandExecutor`. Tests verify:
- Config resolution priority (CLI > ENV > file)
- Mutual exclusion validation
- File existence checks
- Build lifecycle decisions

## Integration Tests

Full end-to-end: compile SakeApp, execute commands, verify output. Use swift-subprocess to run `sake` binary.

## All Tests Are Async

All test methods use `async throws`:
```swift
func testSomething() async throws {
    // ...
}
```
