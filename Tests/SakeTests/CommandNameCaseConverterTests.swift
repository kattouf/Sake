@testable import Sake
import XCTest

final class CommandNameCaseConverterTests: XCTestCase {
    func testKeepOriginalStrategy() {
        let commands: [String: Command] = [
            "commandOne": Command(description: "description1"),
            "commandTwo": Command(description: "description2"),
        ]
        let convertedCommands = CommandNameCaseConverter.convert(commands, strategy: .keepOriginal)
        XCTAssertEqual(Set(convertedCommands.keys), ["commandOne", "commandTwo"])

        let commands2: [String: Command] = [
            "command_one": Command(description: "description1"),
            "command_two": Command(description: "description2"),
        ]
        let convertedCommands2 = CommandNameCaseConverter.convert(commands2, strategy: .keepOriginal)
        XCTAssertEqual(Set(convertedCommands2.keys), ["command_one", "command_two"])

        let commands3: [String: Command] = [
            "command-one": Command(description: "description1"),
            "command-two": Command(description: "description2"),
        ]
        let convertedCommands3 = CommandNameCaseConverter.convert(commands3, strategy: .keepOriginal)
        XCTAssertEqual(Set(convertedCommands3.keys), ["command-one", "command-two"])
    }

    func testToSnakeCaseStrategy() {
        let commands: [String: Command] = [
            "commandOne": Command(description: "description1"),
            "commandTwo": Command(description: "description2"),
        ]
        let convertedCommands = CommandNameCaseConverter.convert(commands, strategy: .toSnakeCase)
        XCTAssertEqual(Set(convertedCommands.keys), ["command_one", "command_two"])

        let commands2: [String: Command] = [
            "command_one": Command(description: "description1"),
            "command_two": Command(description: "description2"),
        ]
        let convertedCommands2 = CommandNameCaseConverter.convert(commands2, strategy: .toSnakeCase)
        XCTAssertEqual(Set(convertedCommands2.keys), ["command_one", "command_two"])

        let commands3: [String: Command] = [
            "command-one": Command(description: "description1"),
            "command-two": Command(description: "description2"),
        ]
        let convertedCommands3 = CommandNameCaseConverter.convert(commands3, strategy: .toSnakeCase)
        XCTAssertEqual(Set(convertedCommands3.keys), ["command_one", "command_two"])
    }

    func testToKebabCaseStrategy() {
        let commands: [String: Command] = [
            "commandOne": Command(description: "description1"),
            "commandTwo": Command(description: "description2"),
        ]
        let convertedCommands = CommandNameCaseConverter.convert(commands, strategy: .toKebabCase)
        XCTAssertEqual(Set(convertedCommands.keys), ["command-one", "command-two"])

        let commands2: [String: Command] = [
            "command_one": Command(description: "description1"),
            "command_two": Command(description: "description2"),
        ]
        let convertedCommands2 = CommandNameCaseConverter.convert(commands2, strategy: .toKebabCase)
        XCTAssertEqual(Set(convertedCommands2.keys), ["command-one", "command-two"])

        let commands3: [String: Command] = [
            "command-one": Command(description: "description1"),
            "command-two": Command(description: "description2"),
        ]
        let convertedCommands3 = CommandNameCaseConverter.convert(commands3, strategy: .toKebabCase)
        XCTAssertEqual(Set(convertedCommands3.keys), ["command-one", "command-two"])
    }
}
