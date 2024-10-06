import ArgumentParser
import Foundation

@main
struct SakeCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sake",
        abstract: "Swift-based utility for managing command execution with dependencies and conditions, inspired by Make.",
        version: sakeCLIVersion,
        subcommands: [InitCommand.self, CleanCommand.self, BuildCommand.self, RunCommand.self, ListCommand.self],
        defaultSubcommand: RunCommand.self
    )
}
