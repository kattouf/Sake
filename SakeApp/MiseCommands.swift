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
            run: { _ in
                try runAndPrint("mise", "install", "swiftformat")
            }
        )
    }

    static var ensureXcbeautifyInstalled: Command {
        Command(
            description: "Ensure xcbeautify is installed",
            skipIf: { _ in
                run("mise", "which", "xcbeautify").succeeded
            },
            run: { _ in
                try runAndPrint("mise", "install", "xcbeautify")
            }
        )
    }

    static var ensureGhInstalled: Command {
        Command(
            description: "Ensure gh is installed",
            skipIf: { _ in
                run("mise", "which", "gh").succeeded
            },
            run: { _ in
                try runAndPrint("mise", "install", "gh")
            }
        )
    }

    static var ensureGitCliffInstalled: Command {
        Command(
            description: "Ensure git-cliff is installed",
            skipIf: { _ in
                run("mise", "which", "git-cliff").succeeded
            },
            run: { _ in
                try runAndPrint("mise", "install", "git-cliff")
            }
        )
    }
}
