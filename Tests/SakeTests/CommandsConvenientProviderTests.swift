@testable import Sake
import XCTest

final class CommandsConvenientProviderTests: XCTestCase {
    func testAllCommands() throws {
        let commands = [
            "command1": Command(description: "description1"),
            "command2": Command(description: "description2"),
        ]
        let commandGroups: [CommandGroup.Type] = [CommandGroupMock1.self, CommandGroupMock2.self]
        let provider = CommandsConvenientProvider(commands: commands, commandGroups: commandGroups, caseConvertingStrategy: .keepOriginal)

        let allCommands = try provider.allCommands()
        let allCommandsIdentifiableData = allCommands.mapValues { $0.description }

        let expectedAllCommands = [
            "command1": "description1",
            "command2": "description2",
            "command3": nil,
            "command4": "description4",
            "command5": "description5",
            "command6": "description6",
        ]

        XCTAssertEqual(allCommandsIdentifiableData, expectedAllCommands)
    }

    func testAllCommandsShouldThrowWhenGroupsHaveCommandsWithTheSameName() throws {
        let commands = [
            "command3": Command(description: "description1"),
            "command2": Command(description: "description2"),
        ]
        let commandGroups: [CommandGroup.Type] = [CommandGroupMock1.self, CommandGroupMock2.self]
        let provider = CommandsConvenientProvider(commands: commands, commandGroups: commandGroups, caseConvertingStrategy: .keepOriginal)

        XCTAssertThrowsError(try provider.allCommands()) { error in
            let sakeAppError = error as! SakeAppError
            if case let .commandDuplicate(error) = sakeAppError {
                XCTAssertTrue(error.contains("command3"))
            } else {
                XCTFail("Unexpected error: \(sakeAppError)")
            }
        }
    }

    func testRootCommands() {
        let commands = [
            "command1": Command(description: "description1"),
            "command2": Command(description: "description2"),
        ]
        let commandGroups: [CommandGroup.Type] = [CommandGroupMock1.self, CommandGroupMock2.self]
        let provider = CommandsConvenientProvider(commands: commands, commandGroups: commandGroups, caseConvertingStrategy: .keepOriginal)

        let rootCommands = provider.rootCommands()
        let rootCommandsIdentifiableData = rootCommands.mapValues { $0.description }

        let expectedRootCommands = [
            "command1": "description1",
            "command2": "description2",
        ]

        XCTAssertEqual(rootCommandsIdentifiableData, expectedRootCommands)
    }

    func testOtherCommandGroups() {
        let commands = [
            "command1": Command(description: "description1"),
            "command2": Command(description: "description2"),
        ]
        let commandGroups: [CommandGroup.Type] = [CommandGroupMock1.self, CommandGroupMock2.self]
        let provider = CommandsConvenientProvider(commands: commands, commandGroups: commandGroups, caseConvertingStrategy: .keepOriginal)

        let otherCommandGroups = provider.otherCommandGroups()
        let otherCommandGroupsIdentifiableData = otherCommandGroups.mapValues { $0.mapValues { $0.description } }

        let expectedOtherCommandGroups = [
            "group1": [
                "command3": nil,
                "command4": "description4",
            ],
            "group2": [
                "command5": "description5",
                "command6": "description6",
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
            "command3": Command(description: nil),
            "command4": Command(description: "description4"),
        ]
    }
}

private struct CommandGroupMock2: CommandGroup {
    static var name: String {
        "group2"
    }

    static var commands: [String: Command] {
        [
            "command5": Command(description: "description5"),
            "command6": Command(description: "description6"),
        ]
    }
}
