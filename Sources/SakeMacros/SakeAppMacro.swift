import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

public struct CommandGroupMacro: ExtensionMacro {
    public static func expansion(
        of _: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo _: [SwiftSyntax.TypeSyntax],
        in _: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        let nonPrivateInstanceVariables = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter {
                let modifiers = $0.modifiers.map(\.name.text)
                return modifiers.contains("public") && modifiers.contains("static")
            }

        let commandsVariableNames: [String] = nonPrivateInstanceVariables.compactMap {
            guard let binding = $0.bindings.first else {
                return nil
            }
            if
                let type = binding.typeAnnotation?.type.as(IdentifierTypeSyntax.self)?.name.text,
                type == "Command"
            {
                return binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            }
            if let memberType = binding.typeAnnotation?.type.as(MemberTypeSyntax.self)?.trimmedDescription,
               memberType == "Sake.Command"
            {
                return binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            }

            return nil
        }
        let commandsAsDictionaryKeyValues = commandsVariableNames.map { "\"\($0)\": Self.\($0)" }.joined(separator: ",\n")
        let commandsDictionary = commandsAsDictionaryKeyValues.isEmpty ? "[:]" : "[\n\(commandsAsDictionaryKeyValues)\n]"

        let syntax = try ExtensionDeclSyntax("""
        extension \(raw: type): Sake.CommandGroup {
            static var commands: [String: Sake.Command] {
                \(raw: commandsDictionary)
            }
        }
        """)

        return [syntax]
    }
}
