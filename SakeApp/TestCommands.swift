import ArgumentParser
import Sake
import SwiftShell

@CommandGroup
struct TestCommands {
    struct TestArguments: ParsableArguments {
        @Flag(name: .long, help: "Clean build artifacts before running tests")
        var clean: Bool = false
    }

    public static var test: Command {
        Command(
            description: "Run tests",
            dependencies: [
                cleanIfNeeded,
                unitTests.mapArguments { arguments in arguments.filter { $0 != "--clean" } },
                integrationTests.mapArguments { arguments in arguments.filter { $0 != "--clean" } },
            ]
        )
    }

    public static var unitTests: Command {
        Command(
            description: "Run unit tests",
            dependencies: [cleanIfNeeded, BrewCommands.ensureXcbeautifyInstalled],
            run: { _ in
                try runAndPrint(bash: "swift test --filter \"^(?!.*\\bIntegrationTests\\b).*\" | xcbeautify")
            }
        )
    }

    public static var integrationTests: Command {
        Command(
            description: "Run integration tests",
            dependencies: [cleanIfNeeded, BrewCommands.ensureXcbeautifyInstalled],
            run: { _ in
                try runAndPrint(bash: "swift test --filter IntegrationTests | xcbeautify")
            }
        )
    }

    static var cleanIfNeeded: Command {
        Command(
            description: "Clean build artifacts",
            skipIf: { context in
                let arguments = try TestArguments.parse(context.arguments)
                return !arguments.clean
            },
            run: { _ in
                try runAndPrint("swift", "package", "clean")
            }
        )
    }
}
