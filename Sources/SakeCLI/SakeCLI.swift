import ArgumentParser
import Foundation

@main
struct SakeCLI: ParsableCommand {
    private static let subcommands: [ParsableCommand.Type] = [
        InitCommand.self,
        CleanCommand.self,
        BuildCommand.self,
        RunCommand.self,
        ListCommand.self,
    ] + platformSpecificSubcommands
    #if os(macOS)
        private static let platformSpecificSubcommands: [ParsableCommand.Type] = [EditCommand.self]
    #else
        private static let platformSpecificSubcommands: [ParsableCommand.Type] = []
    #endif

    static let configuration = CommandConfiguration(
        commandName: "sake",
        abstract: "Swift-based utility for managing command execution with dependencies and conditions, inspired by Make.",
        version: sakeCLIVersion,
        subcommands: subcommands,
        defaultSubcommand: RunCommand.self
    )
}
