import Foundation
@testable import Sake
import XCTest

final class CommandListFormatterTests: XCTestCase {
    func testJSONFormatting() throws {
        let inputData = CommandListFormatter.InputData(
            rootName: "root",
            rootCommands: [
                "command1": Command(description: "description1"),
                "command2": Command(description: "description2"),
            ],
            groupedCommands: [
                "group1": [
                    "command3": Command(description: nil),
                    "command4": Command(description: "description4"),
                ],
                "group2": [
                    "command5": Command(description: "description5"),
                    "command6": Command(description: "description6"),
                ],
            ],
        )
        let json = try CommandListFormatter.json(inputData: inputData)

        struct JSON: Decodable, Equatable {
            struct Command: Decodable, Equatable, Hashable {
                let name: String
                let description: String?
            }

            let groups: [String: [Command]]
        }

        let decoded = try JSONDecoder().decode(JSON.self, from: json.data(using: .utf8)!)

        let expectedDecoded = JSON(groups: [
            "root": [
                .init(name: "command1", description: "description1"),
                .init(name: "command2", description: "description2"),
            ],
            "group1": [
                .init(name: "command3", description: nil),
                .init(name: "command4", description: "description4"),
            ],
            "group2": [
                .init(name: "command5", description: "description5"),
                .init(name: "command6", description: "description6"),
            ],
        ])
        XCTAssertEqual(Set(decoded.groups["root"]!), Set(expectedDecoded.groups["root"]!))
        XCTAssertEqual(Set(decoded.groups["group1"]!), Set(expectedDecoded.groups["group1"]!))
        XCTAssertEqual(Set(decoded.groups["group2"]!), Set(expectedDecoded.groups["group2"]!))
    }

    func testHumanReadableFormatting() {
        let inputData = CommandListFormatter.InputData(
            rootName: "root",
            rootCommands: [
                "command1": Command(description: "description1"),
                "command2": Command(description: "description2"),
            ],
            groupedCommands: [
                "group1": [
                    "command3": Command(description: nil),
                    "command4": Command(description: "description4"),
                ],
                "group2": [
                    "command5": Command(description: "description5"),
                    "command6": Command(description: "description6"),
                ],
            ],
        )
        let humanReadable = CommandListFormatter.humanReadable(inputData: inputData)
        let expectedHumanReadable = """
        root:
         * command1 - description1
         * command2 - description2
        group1:
         * command3
         * command4 - description4
        group2:
         * command5 - description5
         * command6 - description6
        """
        XCTAssertEqual(humanReadable, expectedHumanReadable)
    }
}
