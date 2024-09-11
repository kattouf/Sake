import ArgumentParser
import SakeShared

struct CommonOptions: ParsableArguments {
    @Option(name: .shortAndLong, help: "Specify the path to the configuration file. Defaults to \".sake.yml\" in the current directory.")
    var configPath: String?

    @Option(name: .shortAndLong, help: "Specify the path for the SakeApp package. Defaults to \"SakeApp\" in the current directory.")
    var sakeAppPath: String?
}

struct CommandRelatedCommonOptions: ParsableArguments {
    @Option(name: .long, help: "Specify the strategy for converting command names' case.")
    var caseConvertingStrategy: CaseConvertingStrategy?
}
