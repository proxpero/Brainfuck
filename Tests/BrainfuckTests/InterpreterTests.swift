@testable import Brainfuck
import XCTest

final class InterpreterTests: XCTestCase {
    func testExample() throws {
        let source = ",[.,]"
        let instructions = try Interpreter<UInt8>.parse(source)
        let expectation: [Instruction] = [
            .input,
            .startLoop(endIndex: 5),
            .output,
            .input,
            .endLoop(startIndex: 2),
        ]
        XCTAssertEqual(instructions, expectation)
    }

    func testStepping() throws {
        let source = "+[>+]"
        var interpreter = try Interpreter<UInt8>(source, memorySize: 6)
        let instructions = interpreter.instructions
        let expectation: [Instruction] = [
            .plus,
            .startLoop(endIndex: 5),
            .right,
            .plus,
            .endLoop(startIndex: 2),
        ]
        XCTAssertEqual(instructions, expectation)
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        try interpreter.step()
        XCTAssertEqual(interpreter.data, [1, 1, 1, 1, 1, 1])
    }

    func testAddTwoNumbers() throws {
        let source = "[->+<]"
        var interpreter = try Interpreter<UInt8>(source, data: [3, 4])
        try interpreter.run()
        XCTAssertEqual(interpreter.data[0], 0)
        XCTAssertEqual(interpreter.data[1], 7)
    }

    func testOutput() throws {
        let source = "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
        var interpreter = try Interpreter<UInt8>(source)
        try interpreter.run()
        XCTAssertEqual(interpreter.output, "Hello World!\n")
    }
}
