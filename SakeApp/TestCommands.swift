import ArgumentParser
import Sake
import SakeSwiftShell
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
                buildTests,
                unitTests.mapArguments { arguments in arguments + ["--skip-build"] },
                integrationTests.mapArguments { arguments in arguments + ["--skip-build"] },
            ]
        )
    }

    public static var buildTests: Command {
        Command(
            description: "Build tests",
            dependencies: [cleanIfNeeded],
            skipIf: { context in
                let arguments = try TestArguments.parse(context.arguments)
                return arguments.skipBuild
            },
            run: { context in
                try interruptableRunAndPrint(bash: "swift build --build-tests", interruptionHandler: context.interruptionHandler)
            }
        )
    }

    public static var unitTests: Command {
        Command(
            description: "Run unit tests",
            dependencies: [buildTests],
            run: { context in
                let shouldBeautifyLog = context.environment["GITHUB_ACTIONS"] == nil
                let beautifyLog = shouldBeautifyLog ? " | mise exec -- xcbeautify --disable-logging" : ""
                if shouldBeautifyLog {
                    try await CommandRunner(
                        command: MiseCommands.ensureXcbeautifyInstalled,
                        context: context
                    )
                    .run()
                }
                try interruptableRunAndPrint(
                    bash: "swift test --skip-build --filter \"^(?!.*\\bIntegrationTests\\b).*\"\(beautifyLog)",
                    interruptionHandler: context.interruptionHandler
                )
            }
        )
    }

    public static var integrationTests: Command {
        Command(
            description: "Run integration tests",
            dependencies: [buildTests],
            run: { context in
                let shouldBeautifyLog = context.environment["GITHUB_ACTIONS"] == nil
                let beautifyLog = shouldBeautifyLog ? " | mise exec -- xcbeautify --disable-logging" : ""
                if shouldBeautifyLog {
                    try await CommandRunner(
                        command: MiseCommands.ensureXcbeautifyInstalled,
                        context: context
                    )
                    .run()
                }
                try interruptableRunAndPrint(
                    bash: "swift test --skip-build --filter IntegrationTests\(beautifyLog)",
                    interruptionHandler: context.interruptionHandler
                )
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
            run: { context in
                try interruptableRunAndPrint(bash: "swift package clean", interruptionHandler: context.interruptionHandler)
            }
        )
    }
}
