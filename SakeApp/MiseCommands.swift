import Sake
import SwiftShell

@CommandGroup
struct MiseCommands {
    static var ensureSwiftFormatInstalled: Command {
        Command(
            description: "Ensure swiftformat is installed",
            skipIf: { _ in
                run("mise", "which", "swiftformat").succeeded
            },
            run: { context in
                try interruptableRunAndPrint(bash: "mise install swiftformat", interruptionHandler: context.interruptionHandler)
            }
        )
    }

    static var ensureXcbeautifyInstalled: Command {
        Command(
            description: "Ensure xcbeautify is installed",
            skipIf: { _ in
                run("mise", "which", "xcbeautify").succeeded
            },
            run: { context in
                try interruptableRunAndPrint(bash: "mise install xcbeautify", interruptionHandler: context.interruptionHandler)
            }
        )
    }

    static var ensureGhInstalled: Command {
        Command(
            description: "Ensure gh is installed",
            skipIf: { _ in
                run("mise", "which", "gh").succeeded
            },
            run: { context in
                try interruptableRunAndPrint(bash: "mise install gh", interruptionHandler: context.interruptionHandler)
            }
        )
    }

    static var ensureGitCliffInstalled: Command {
        Command(
            description: "Ensure git-cliff is installed",
            skipIf: { _ in
                run("mise", "which", "git-cliff").succeeded
            },
            run: { context in
                try interruptableRunAndPrint(bash: "mise install git-cliff", interruptionHandler: context.interruptionHandler)
            }
        )
    }
}
