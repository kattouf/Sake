import ArgumentParser
import SakeShared

package struct CommonOptions: ParsableArguments {
    package init() {}

    @Option(
        name: .shortAndLong,
        help: "Specify the path to the configuration file. Defaults to \".sake.yml\" in the current directory.",
        completion: .file(),
    )
    package var configPath: String?

    @Option(
        name: .shortAndLong,
        help: "Specify the path for the SakeApp package. Defaults to \"SakeApp\" in the current directory.",
        completion: .directory,
    )
    package var sakeAppPath: String?
}

package struct CommandRelatedCommonOptions: ParsableArguments {
    package init() {}

    @Option(
        name: [.long, .customShort("b")],
        help: "Specify the path to the prebuilt SakeApp binary.\nThis is used to share the ready to use binary and avoid build process (between CI runs for example).",
        completion: .file(),
    )
    package var sakeAppPrebuiltBinaryPath: String?

    @Option(name: .long, help: "Specify the strategy for converting command names' case.")
    package var caseConvertingStrategy: CaseConvertingStrategy?
}
