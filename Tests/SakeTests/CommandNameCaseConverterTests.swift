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
    }

    func testToSnakeCaseStrategy() {
        let commands: [String: Command] = [
            "commandOne": Command(description: "description1"),
            "commandTwo": Command(description: "description2"),
        ]
        let convertedCommands = CommandNameCaseConverter.convert(commands, strategy: .toSnakeCase)
        XCTAssertEqual(Set(convertedCommands.keys), ["command_one", "command_two"])
    }

    func testToKebabCaseStrategy() {
        let commands: [String: Command] = [
            "commandOne": Command(description: "description1"),
            "commandTwo": Command(description: "description2"),
        ]
        let convertedCommands = CommandNameCaseConverter.convert(commands, strategy: .toKebabCase)
        XCTAssertEqual(Set(convertedCommands.keys), ["command-one", "command-two"])
    }
}
