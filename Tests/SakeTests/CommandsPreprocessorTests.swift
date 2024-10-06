@testable import Sake
import XCTest

final class CommandsPreprocessorTests: XCTestCase {
    func testAllCommands() throws {
        let commands = [
            "myCommand1": Command(description: "description1"),
            "myCommand2": Command(description: "description2"),
        ]
        let commandGroups: [CommandGroup.Type] = [CommandGroupMock1.self, CommandGroupMock2.self]
        let provider = CommandsPreprocessor(commands: commands, commandGroups: commandGroups, caseConvertingStrategy: .toSnakeCase)

        let allCommands = try provider.allCommands()
        let allCommandsIdentifiableData = allCommands.mapValues { $0.description }

        let expectedAllCommands = [
            "my_command1": "description1",
            "my_command2": "description2",
            "my_command3": nil,
            "my_command4": "description4",
            "my_command5": "description5",
            "my_command6": "description6",
        ]
        XCTAssertEqual(allCommandsIdentifiableData, expectedAllCommands)
    }

    func testAllCommandsShouldThrowWhenGroupsHaveCommandsWithTheSameName() throws {
        let commands = [
            "myCommand3": Command(description: "description1"),
            "myCommand2": Command(description: "description2"),
        ]
        let commandGroups: [CommandGroup.Type] = [CommandGroupMock1.self, CommandGroupMock2.self]
        let provider = CommandsPreprocessor(commands: commands, commandGroups: commandGroups, caseConvertingStrategy: .toSnakeCase)

        XCTAssertThrowsError(try provider.allCommands()) { error in
            let sakeAppError = error as! SakeAppError
            if case let .commandDuplicate(error) = sakeAppError {
                XCTAssertTrue(error.contains("my_command3"))
            } else {
                XCTFail("Unexpected error: \(sakeAppError)")
            }
        }
    }

    func testRootCommands() {
        let commands = [
            "myCommand1": Command(description: "description1"),
            "myCommand2": Command(description: "description2"),
        ]
        let commandGroups: [CommandGroup.Type] = [CommandGroupMock1.self, CommandGroupMock2.self]
        let provider = CommandsPreprocessor(commands: commands, commandGroups: commandGroups, caseConvertingStrategy: .toSnakeCase)

        let rootCommands = provider.rootCommands()
        let rootCommandsIdentifiableData = rootCommands.mapValues { $0.description }

        let expectedRootCommands = [
            "my_command1": "description1",
            "my_command2": "description2",
        ]

        XCTAssertEqual(rootCommandsIdentifiableData, expectedRootCommands)
    }

    func testOtherCommandGroups() {
        let commands = [
            "myCommand1": Command(description: "description1"),
            "myCommand2": Command(description: "description2"),
        ]
        let commandGroups: [CommandGroup.Type] = [CommandGroupMock1.self, CommandGroupMock2.self]
        let provider = CommandsPreprocessor(commands: commands, commandGroups: commandGroups, caseConvertingStrategy: .toSnakeCase)

        let otherCommandGroups = provider.otherCommandGroups()
        let otherCommandGroupsIdentifiableData = otherCommandGroups.mapValues { $0.mapValues { $0.description } }

        let expectedOtherCommandGroups = [
            "group1": [
                "my_command3": nil,
                "my_command4": "description4",
            ],
            "group2": [
                "my_command5": "description5",
                "my_command6": "description6",
            ],
        ]

        XCTAssertEqual(otherCommandGroupsIdentifiableData, expectedOtherCommandGroups)
    }
}

private struct CommandGroupMock1: CommandGroup {
    static var name: String {
        "group1"
    }

    static var commands: [String: Command] {
        [
            "myCommand3": Command(description: nil),
            "myCommand4": Command(description: "description4"),
        ]
    }
}

private struct CommandGroupMock2: CommandGroup {
    static var name: String {
        "group2"
    }

    static var commands: [String: Command] {
        [
            "myCommand5": Command(description: "description5"),
            "myCommand6": Command(description: "description6"),
        ]
    }
}
