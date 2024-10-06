@testable import Sake
import XCTest

final class CommandMapTests: XCTestCase {
    func testCommandContextMapArguments() throws {
        let commandContext = Command.Context(
            arguments: ["--option1", "value1", "--option2", "value2", "argument1", "argument2"],
            environment: ["foo": "bar"],
            appDirectory: "/path/to/app",
            runDirectory: "/path/to/run"
        )

        let mappedCommandContext = try commandContext.mapArguments { arguments in
            arguments.filter { !$0.hasPrefix("--") }
        }

        XCTAssertEqual(mappedCommandContext.arguments, ["value1", "value2", "argument1", "argument2"])
        XCTAssertEqual(mappedCommandContext.environment, commandContext.environment)
        XCTAssertEqual(mappedCommandContext.appDirectory, commandContext.appDirectory)
        XCTAssertEqual(mappedCommandContext.runDirectory, commandContext.runDirectory)
    }

    func testCommandContextMapEnvironment() throws {
        let commandContext = Command.Context(
            arguments: ["--option1", "value1", "--option2", "value2", "argument1", "argument2"],
            environment: ["foo": "bar"],
            appDirectory: "/path/to/app",
            runDirectory: "/path/to/run"
        )

        let mappedCommandContext = try commandContext.mapEnvironment { environment in
            environment.merging(["baz": "qux"]) { $1 }
        }

        XCTAssertEqual(mappedCommandContext.arguments, commandContext.arguments)
        XCTAssertEqual(mappedCommandContext.environment, ["foo": "bar", "baz": "qux"])
        XCTAssertEqual(mappedCommandContext.appDirectory, commandContext.appDirectory)
        XCTAssertEqual(mappedCommandContext.runDirectory, commandContext.runDirectory)
    }

    func testCommandMapArguments() async throws {
        nonisolated(unsafe) var skipIfContext: Command.Context?
        nonisolated(unsafe) var runContext: Command.Context?
        let command = Command(
            description: "description",
            dependencies: [],
            runDependenciesConcurrently: false,
            skipIf: { context in
                skipIfContext = context
                return false
            },
            run: { context in
                runContext = context
            }
        )

        let context = Command.Context(
            arguments: ["--option1", "value1", "--option2", "value2", "argument1", "argument2"],
            environment: ["foo": "bar"],
            appDirectory: "/path/to/app",
            runDirectory: "/path/to/run"
        )

        let mappedCommand = command.mapArguments { arguments in
            arguments.filter { !$0.hasPrefix("--") }
        }
        _ = try mappedCommand.skipIf(context)
        try await mappedCommand.run(context)

        XCTAssertEqual(skipIfContext?.arguments, ["value1", "value2", "argument1", "argument2"])
        XCTAssertEqual(skipIfContext?.environment, context.environment)
        XCTAssertEqual(skipIfContext?.appDirectory, context.appDirectory)
        XCTAssertEqual(skipIfContext?.runDirectory, context.runDirectory)

        XCTAssertEqual(runContext?.arguments, ["value1", "value2", "argument1", "argument2"])
        XCTAssertEqual(runContext?.environment, context.environment)
        XCTAssertEqual(runContext?.appDirectory, context.appDirectory)
        XCTAssertEqual(runContext?.runDirectory, context.runDirectory)
    }

    func testCommandMapEnvironment() async throws {
        nonisolated(unsafe) var skipIfContext: Command.Context?
        nonisolated(unsafe) var runContext: Command.Context?
        let command = Command(
            description: "description",
            dependencies: [],
            runDependenciesConcurrently: false,
            skipIf: { context in
                skipIfContext = context
                return false
            },
            run: { context in
                runContext = context
            }
        )

        let context = Command.Context(
            arguments: ["--option1", "value1", "--option2", "value2", "argument1", "argument2"],
            environment: ["foo": "bar"],
            appDirectory: "/path/to/app",
            runDirectory: "/path/to/run"
        )

        let mappedCommand = command.mapEnvironment { environment in
            environment.merging(["baz": "qux"]) { $1 }
        }
        _ = try mappedCommand.skipIf(context)
        try await mappedCommand.run(context)

        XCTAssertEqual(skipIfContext?.arguments, context.arguments)
        XCTAssertEqual(skipIfContext?.environment, ["foo": "bar", "baz": "qux"])
        XCTAssertEqual(skipIfContext?.appDirectory, context.appDirectory)
        XCTAssertEqual(skipIfContext?.runDirectory, context.runDirectory)

        XCTAssertEqual(runContext?.arguments, context.arguments)
        XCTAssertEqual(runContext?.environment, ["foo": "bar", "baz": "qux"])
        XCTAssertEqual(runContext?.appDirectory, context.appDirectory)
        XCTAssertEqual(runContext?.runDirectory, context.runDirectory)
    }
}
