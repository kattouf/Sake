@testable import Sake
import XCTest

final class CommandRunnerTests: XCTestCase {
    func testSimpleRun() async throws {
        nonisolated(unsafe) var runnedCommands: [String] = []

        let command = Command(
            skipIf: { _ in
                runnedCommands.append("skipIf")
                return false
            },
            run: { _ in
                runnedCommands.append("run")
            },
        )

        let runner = CommandRunner(command: command, context: .empty)
        try await runner.run()

        XCTAssertEqual(runnedCommands, ["skipIf", "run"])
    }

    func testSkipSimpleRun() async throws {
        nonisolated(unsafe) var runnedCommands: [String] = []

        let command = Command(
            skipIf: { _ in
                runnedCommands.append("skipIf")
                return true
            },
            run: { _ in
                runnedCommands.append("run")
            },
        )

        let runner = CommandRunner(command: command, context: .empty)
        try await runner.run()

        XCTAssertEqual(runnedCommands, ["skipIf"])
    }

    func testRunWithNestedDependencies() async throws {
        nonisolated(unsafe) var runnedCommands: [String] = []

        let dependency1 = Command(
            run: { _ in
                runnedCommands.append("dependency1")
            },
        )

        let dependency2 = Command(
            dependencies: [dependency1],
            run: { _ in
                runnedCommands.append("dependency2")
            },
        )

        let dependency3 = Command(
            dependencies: [dependency2],
            run: { _ in
                runnedCommands.append("dependency3")
            },
        )

        let command = Command(
            dependencies: [dependency3],
            run: { _ in
                runnedCommands.append("command")
            },
        )

        let runner = CommandRunner(command: command, context: .empty)
        try await runner.run()

        XCTAssertEqual(runnedCommands, ["dependency1", "dependency2", "dependency3", "command"])
    }

    func testSkipDependencySubtreeRun() async throws {
        nonisolated(unsafe) var runnedCommands: [String] = []

        let dependency1 = Command(
            run: { _ in
                runnedCommands.append("dependency1")
            },
        )

        let dependency2 = Command(
            dependencies: [dependency1],
            skipIf: { _ in
                runnedCommands.append("skipIf2")
                return true
            },
            run: { _ in
                runnedCommands.append("dependency2")
            },
        )

        let dependency3 = Command(
            dependencies: [dependency2],
            run: { _ in
                runnedCommands.append("dependency3")
            },
        )

        let command = Command(
            dependencies: [dependency3],
            run: { _ in
                runnedCommands.append("command")
            },
        )

        let runner = CommandRunner(command: command, context: .empty)
        try await runner.run()

        XCTAssertEqual(runnedCommands, ["skipIf2", "dependency3", "command"])
    }

    func testSharingDataBetweenCommandsViaContextStorage() async throws {
        nonisolated(unsafe) var runnedCommands: [String] = []

        let dependency1 = Command(
            run: { context in
                context.storage["someKey"] = "someData"
                runnedCommands.append("dependency1")
            },
        )

        let dependency2 = Command(
            dependencies: [dependency1],
            run: { context in
                XCTAssertEqual(context.storage["someKey"] as? String, "someData")
                runnedCommands.append("dependency2")
            },
        )

        let dependency3 = Command(
            dependencies: [dependency2],
            run: { context in
                XCTAssertEqual(context.storage["someKey"] as? String, "someData")
                context.storage["someKey"] = "otherData"
                runnedCommands.append("dependency3")
            },
        )

        let command = Command(
            dependencies: [dependency3],
            run: { context in
                XCTAssertEqual(context.storage["someKey"] as? String, "otherData")
                runnedCommands.append("command")
            },
        )

        let runner = CommandRunner(command: command, context: .empty)
        try await runner.run()

        XCTAssertEqual(runnedCommands, ["dependency1", "dependency2", "dependency3", "command"])
    }
}

private extension Command.Context {
    static var empty: Command.Context {
        Command.Context(
            arguments: [],
            environment: [:],
            appDirectory: "",
            runDirectory: "",
            storage: .init(),
            interruptionHandler: .init(processMonitor: .init()),
        )
    }
}
