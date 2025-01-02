import ArgumentParser
import Sake
import SwiftShell

@CommandGroup
struct TestCommands {
    struct TestArguments: ParsableArguments {
        @Flag(name: .long, help: "Clean build artifacts before running tests")
        var clean: Bool = false

        @Flag(name: .long, help: "Skip building before running tests")
        var skipBuild: Bool = false
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

    public static var buildTests: Command {
        Command(
            description: "Build tests",
            dependencies: [cleanIfNeeded],
            run: { _ in
                try runAndPrint(bash: "swift build --build-tests")
            }
        )
    }

    public static var unitTests: Command {
        Command(
            description: "Run unit tests",
            dependencies: [cleanIfNeeded],
            run: { context in
                let arguments = try TestArguments.parse(context.arguments)
                let skipBuild = arguments.skipBuild ? " --skip-build" : ""
                let shouldBeautifyLog = context.environment["GITHUB_ACTIONS"] == nil
                let beautifyLog = shouldBeautifyLog ? " | mise exec -- xcbeautify --disable-logging" : ""
                if shouldBeautifyLog {
                    try await CommandRunner(
                        command: MiseCommands.ensureXcbeautifyInstalled,
                        context: context
                    )
                    .run()
                }
                try runAndPrint(bash: "swift test --filter \"^(?!.*\\bIntegrationTests\\b).*\"\(skipBuild)\(beautifyLog)")
            }
        )
    }

    public static var integrationTests: Command {
        Command(
            description: "Run integration tests",
            dependencies: [cleanIfNeeded],
            run: { context in
                let arguments = try TestArguments.parse(context.arguments)
                let skipBuild = arguments.skipBuild ? " --skip-build" : ""
                let shouldBeautifyLog = context.environment["GITHUB_ACTIONS"] == nil
                let beautifyLog = shouldBeautifyLog ? " | mise exec -- xcbeautify --disable-logging" : ""
                if shouldBeautifyLog {
                    try await CommandRunner(
                        command: MiseCommands.ensureXcbeautifyInstalled,
                        context: context
                    )
                    .run()
                }
                try runAndPrint(bash: "swift test --filter IntegrationTests\(skipBuild)\(beautifyLog)")
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
