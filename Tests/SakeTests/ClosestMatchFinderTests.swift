@testable import Sake
import XCTest

final class ClosestMatchFinderTests: XCTestCase {
    func testFindClosestMatch() {
        let finder = ClosestMatchFinder(candidates: ["dog", "cat", "fish"])

        XCTAssertEqual(finder.findClosestMatches(to: "dov", maxDistance: 1), ["dog"])
        XCTAssertEqual(finder.findClosestMatches(to: "dovg", maxDistance: 1), ["dog"])
        XCTAssertEqual(finder.findClosestMatches(to: "dovk", maxDistance: 1), [])
        XCTAssertEqual(finder.findClosestMatches(to: "dovk", maxDistance: 2), ["dog"])
    }
}
