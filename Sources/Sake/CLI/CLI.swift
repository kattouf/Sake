import ArgumentParser
import SakeShared

struct CLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        subcommands: [ListCommand.self, RunCommand.self]
    )
}

struct CommonOptions: ParsableArguments {
    @Option
    var caseConvertingStrategy: CaseConvertingStrategy
}
