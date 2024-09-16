import ArgumentParser
import SakeShared

struct CLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        subcommands: [ListCommand.self, RunCommand.self]
    )
}

struct ListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list"
    )

    @OptionGroup
    var options: CommonOptions
}

struct RunCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "run"
    )

    @OptionGroup
    var options: CommonOptions

    @Argument
    var command: String

    @Argument(parsing: .allUnrecognized)
    var args: [String] = []
}

struct CommonOptions: ParsableArguments {
    @Option
    var caseConvertingStrategy: CaseConvertingStrategy

    @Flag
    var json: Bool = false
}
