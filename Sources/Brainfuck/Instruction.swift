enum Instruction: Equatable {
    /// Increment the pointer.
    case right

    /// Decrement the pointer.
    case left

    /// Increment the byte at the pointer.
    case plus

    /// Decrement the byte at the pointer.
    case minus

    /// Read the byte at the pointer and write it to user output.
    case output

    /// Read a byte from user input and write it to the location at the pointer.
    case input

    /// Jump forward past `endIndex` if the byte at the pointer is zero.
    case startLoop(endIndex: Int)

    /// Jump backward to `startIndex`, unless the byte at the pointer is zero.
    case endLoop(startIndex: Int)
}

extension Instruction {
    init?(char: Character, index: Int) {
        switch char {
        case ">": self = .right
        case "<": self = .left
        case "+": self = .plus
        case "-": self = .minus
        case ".": self = .output
        case ",": self = .input
        case "[": self = .startLoop(endIndex: index)
        case "]": self = .endLoop(startIndex: index)
        default: return nil
        }
    }
}

extension Instruction: CustomStringConvertible {
    var description: String {
        switch self {
        case .left:
            return "<"
        case .right:
            return ">"
        case .minus:
            return "-"
        case .plus:
            return "+"
        case .input:
            return ","
        case .output:
            return "."
        case .startLoop:
            return "["
        case .endLoop:
            return "]"
        }
    }
}
