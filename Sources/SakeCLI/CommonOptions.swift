import ArgumentParser
import SakeShared

struct CommonOptions: ParsableArguments {
    @Option(
        name: .shortAndLong,
        help: "Specify the path to the configuration file. Defaults to \".sake.yml\" in the current directory.",
        completion: .file()
    )
    var configPath: String?

    @Option(
        name: .shortAndLong,
        help: "Specify the path for the SakeApp package. Defaults to \"SakeApp\" in the current directory.",
        completion: .directory
    )
    var sakeAppPath: String?
}

struct CommandRelatedCommonOptions: ParsableArguments {
    @Option(
        name: [.long, .customShort("b")],
        help: "Specify the path to the prebuilt SakeApp binary.\nThis is used to share the ready to use binary and avoid build process (between CI runs for example).",
        completion: .file()
    )
    var sakeAppPrebuiltBinaryPath: String?

    @Option(name: .long, help: "Specify the strategy for converting command names' case.")
    var caseConvertingStrategy: CaseConvertingStrategy?
}
