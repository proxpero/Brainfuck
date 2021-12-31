import XCTest
@testable import Brainfuck

final class BrainfuckTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Brainfuck().text, "Hello, World!")
    }
}
