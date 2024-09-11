import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [CommandGroupMacro.self]
}
