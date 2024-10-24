import Sake
import SwiftShell

@CommandGroup
struct BrewCommands {
    static var ensureSwiftFormatInstalled: Command {
        Command(
            description: "Ensure swiftformat is installed",
            skipIf: { _ in
                run("which", "swiftformat").succeeded
            },
            run: { _ in
                try runAndPrint("brew", "install", "swiftformat")
            }
        )
    }

    static var ensureXcbeautifyInstalled: Command {
        Command(
            description: "Ensure xcbeautify is installed",
            skipIf: { _ in
                run("which", "xcbeautify").succeeded
            },
            run: { _ in
                try runAndPrint("brew", "install", "xcbeautify")
            }
        )
    }

    static var ensureGhInstalled: Command {
        Command(
            description: "Ensure gh is installed",
            skipIf: { _ in
                run("which", "gh").succeeded
            },
            run: { _ in
                try runAndPrint("brew", "install", "gh")
            }
        )
    }

    static var ensureGitCliffInstalled: Command {
        Command(
            description: "Ensure git-cliff is installed",
            skipIf: { _ in
                run("which", "git-cliff").succeeded
            },
            run: { _ in
                try runAndPrint("brew", "install", "git-cliff")
            }
        )
    }
}
