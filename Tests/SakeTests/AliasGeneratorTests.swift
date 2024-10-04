@testable import Sake
import XCTest

final class AliasGeneratorTests: XCTestCase {
    func testGenerate() {
        let phrases = [
            "command_aqua",
            "command_apple",
            "command_beer",
            "command_boo",
            "command_book",
            "command_duck",
            "command_car",
            "command",
            ""
        ]
        let aliases = AliasGenerator.generateAliases(for: phrases)
        XCTAssertEqual(aliases["command_aqua"], "caq")
        XCTAssertEqual(aliases["command_apple"], "cap")
        XCTAssertEqual(aliases["command_boo"], "cboo")
        XCTAssertEqual(aliases["command_book"], "cbook")
        XCTAssertEqual(aliases["command_beer"], "cbe")
        XCTAssertEqual(aliases["command_duck"], "cd")
        XCTAssertEqual(aliases["command_car"], "cc")
        XCTAssertEqual(aliases["command"], "c")
        XCTAssertNil(aliases[""])
    }
}
