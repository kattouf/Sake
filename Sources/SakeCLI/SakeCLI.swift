import ArgumentParser
import Foundation

@main
struct SakeCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "sake",
        abstract: "Swift-based utility for managing CLI command execution with dependencies and conditions, inspired by Make.",
        subcommands: [InitCommand.self, CleanCommand.self, RunCommand.self, ListCommand.self],
        defaultSubcommand: RunCommand.self
    )
}
