---
name: sake-macro-development
description: Use when modifying the @CommandGroup macro in SakeMacros target — SwiftSyntax ExtensionMacro, code generation patterns, testing with assertMacroExpansion.
---

# Sake Macro Development

Reference for working on the `@CommandGroup` Swift macro.

## What the Macro Does

`@CommandGroup` is an `ExtensionMacro` that generates:
1. `CommandGroup` protocol conformance
2. A `commands` computed property — dictionary of all public static Command vars

```swift
// Input
@CommandGroup
struct MyCommands {
    public static var hello: Command { ... }
    public static var bye: Sake.Command { ... }
    static var internal: Command { ... }       // excluded: not public
    private var foo: Command { ... }           // excluded: not public, not static
}

// Generated
extension MyCommands: Sake.CommandGroup {
    static var commands: [String: Sake.Command] {
        ["hello": Self.hello, "bye": Self.bye]
    }
}
```

## Inclusion Criteria

A property is included in `commands` only if ALL of:
- Has `public` modifier
- Has `static` modifier
- Type annotation is exactly `Command` or `Sake.Command`

Typealiases, inferred types, or other spellings are NOT detected.

## Implementation

File: `Sources/SakeMacros/SakeAppMacro.swift`

```swift
public struct CommandGroupMacro: ExtensionMacro {
    public static func expansion(...) throws -> [ExtensionDeclSyntax] {
        // 1. Filter members: public + static
        // 2. Check type annotation: Command or Sake.Command
        // 3. Extract variable names
        // 4. Generate dictionary literal
        // 5. Return extension with CommandGroup conformance
    }
}
```

Plugin registration: `Sources/SakeMacros/Plugin.swift`

## SwiftSyntax Patterns Used

- `declaration.memberBlock.members` — iterate struct members
- `.compactMap { $0.decl.as(VariableDeclSyntax.self) }` — get variable declarations
- `$0.modifiers.map(\.name.text)` — check access modifiers
- `binding.typeAnnotation?.type.as(IdentifierTypeSyntax.self)` — simple type (`Command`)
- `binding.typeAnnotation?.type.as(MemberTypeSyntax.self)` — qualified type (`Sake.Command`)
- `binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text` — variable name
- `ExtensionDeclSyntax("""...""")` — string interpolation for generating syntax

## Testing

File: `Tests/SakeMacrosTests/SakeAppMacroTests.swift`

Uses `SwiftSyntaxMacrosTestSupport`:

```swift
import SakeMacros
import SwiftSyntaxMacrosTestSupport

assertMacroExpansion(
    """
    @CommandGroup
    struct MyCommands {
        public static var hello: Command { ... }
    }
    """,
    expandedSource: """
    struct MyCommands {
        public static var hello: Command { ... }
    }

    extension MyCommands: Sake.CommandGroup {
        static var commands: [String: Sake.Command] {
            ["hello": Self.hello]
        }
    }
    """,
    macros: ["CommandGroup": CommandGroupMacro.self],
)
```

Key test cases:
- Multiple commands with mixed visibility (public, private, static, non-static)
- Both `Command` and `Sake.Command` type annotations
- Zero commands → generates `[:]`

## Dependencies

```swift
// Package.swift
.macro(name: "SakeMacros", dependencies: [
    .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
    .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
])
```

swift-syntax version: 602.0.0+
