import Sake

@CommandGroup
struct MiseCommands {
    static var ensureSwiftFormatInstalled: Command {
        Command(
            description: "Ensure swiftformat is installed",
            skipIf: { _ in
                try await run("mise", "which", "swiftformat").terminationStatus.isSuccess
            },
            run: { _ in
                try await runAndPrint("mise", "install", "swiftformat")
            }
        )
    }

    static var ensureXcbeautifyInstalled: Command {
        Command(
            description: "Ensure xcbeautify is installed",
            skipIf: { _ in
                try await run("mise", "which", "xcbeautify").terminationStatus.isSuccess
            },
            run: { _ in
                try await runAndPrint("mise", "install", "xcbeautify")
            }
        )
    }

    static var ensureGhInstalled: Command {
        Command(
            description: "Ensure gh is installed",
            skipIf: { _ in
                try await run("mise", "which", "gh").terminationStatus.isSuccess
            },
            run: { _ in
                try await runAndPrint("mise", "install", "gh")
            }
        )
    }

    static var ensureGitCliffInstalled: Command {
        Command(
            description: "Ensure git-cliff is installed",
            skipIf: { _ in
                try await run("mise", "which", "git-cliff").terminationStatus.isSuccess
            },
            run: { _ in
                try await runAndPrint("mise", "install", "git-cliff")
            }
        )
    }
}
