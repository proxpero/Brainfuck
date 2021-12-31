public struct Interpreter<Byte> where Byte: FixedWidthInteger {
    private(set) var dataIndex: Int
    private(set) var data: [Byte]
    let instructions: [Instruction]
    private(set) var instructionIndex: Int
    let input: [Character]
    private(set) var inputIndex: Int
    private var charOutput: [Character]

    /// Create a Brainfuck Interpreter.
    /// - Parameters:
    ///   - source: The Brainfuck source code to interpret.
    ///   - data: Optionally set an initial state of the data that will be operated on.
    ///   - input: Opionally set a string of input characters.
    ///   - memorySize: The size of the `memory tape` that the interpreter will use (default = 256).
    public init(_ source: String, data: [Byte]? = nil, input: String = "", memorySize: Int = 256) throws {
        self.data = data ?? Array<Byte>.init(repeating: 0, count: memorySize)
        self.dataIndex = self.data.startIndex
        self.instructions = try Self.parse(source)
        self.instructionIndex = instructions.startIndex
        self.input = input.map { $0 }
        self.inputIndex = self.input.startIndex
        self.charOutput = []
    }
}

extension Interpreter {
    static func parse(_ source: String) throws -> [Instruction] {
        var bracketIndices: [Int] = []
        var result: [Instruction] = []

        for (index, char) in zip(0..., source) {
            guard var token = Instruction(char: char, index: index) else { continue }
            switch token {
            case .startLoop:
                bracketIndices.append(index)
            case .endLoop:
                guard !bracketIndices.isEmpty else {
                    throw ParseError.tooManyCloseBrackets
                }
                let startIndex = bracketIndices.removeLast()
                token = .endLoop(startIndex: startIndex + 1)
                result[startIndex] = .startLoop(endIndex: index + 1)
            default:
                break
            }
            result.append(token)
        }

        return result
    }
}

public extension Interpreter {
    var hasOutput: Bool {
        !charOutput.isEmpty
    }

    var output: String {
        String(charOutput)
    }

    var isHalted: Bool {
        instructionIndex >= instructions.endIndex
    }

    mutating func run() throws {
        while !isHalted {
            try step()
        }
    }

    mutating func step() throws {
        if isHalted { return }
        let instruction = instructions[instructionIndex]
        instructionIndex = instructions.index(after: instructionIndex)
        try execute(instruction)
    }
}

private extension Interpreter {
    var isCurrentByteZero: Bool {
        dataIndex >= data.endIndex || data[dataIndex] == 0
    }

    mutating func incrementDataIndex(_ value: Int) throws {
        let newIndex = dataIndex + value
        guard newIndex >= data.startIndex else {
            throw RuntimeError.invalidDataIndex(instructionIndex: instructionIndex)
        }
        dataIndex = newIndex
    }

    mutating func padDataIfNecessary() {
        let diff = data.count - dataIndex
        if diff < 0 { data.append(contentsOf: [Byte](repeating: 0, count: diff)) }
    }

    mutating func incrementDataValue() {
        padDataIfNecessary()
        data[dataIndex] = data[dataIndex] &+ 1
    }

    mutating func decrementDataValue() {
        padDataIfNecessary()
        data[dataIndex] = data[dataIndex] &- 1
    }

    mutating func setInstructionIndex(_ newIndex: Int) throws {
        guard instructions.indices.contains(newIndex) else {
            throw RuntimeError.invalidInstructionIndex(current: instructionIndex, proposedValue: newIndex)
        }
        instructionIndex = newIndex
    }

    mutating func readInput() {
        padDataIfNecessary()
        var value: Byte = 0
        if input.indices.contains(inputIndex), let code = input[inputIndex].asciiValue {
            value = Byte(code)
        }
        data[dataIndex] = value
    }

    mutating func writeOutput() throws {
        guard data.indices.contains(dataIndex) else {
            throw RuntimeError.invalidDataIndex(instructionIndex: instructionIndex)
        }
        charOutput.append(.init(.init(UInt8(data[dataIndex]))))
    }

    mutating func execute(_ instruction: Instruction) throws {
        switch instruction {
        case .right:
            try incrementDataIndex(1)
        case .left:
            try incrementDataIndex(-1)
        case .plus:
            incrementDataValue()
        case .minus:
            decrementDataValue()
        case .output:
            try writeOutput()
        case .input:
            readInput()
        case .startLoop(let endIndex):
            if isCurrentByteZero {
                try setInstructionIndex(endIndex)
            }
        case .endLoop(let startIndex):
            if !isCurrentByteZero {
                try setInstructionIndex(startIndex)
            }
        }
    }
}

extension Interpreter {
    enum ParseError: Swift.Error {
        case tooManyCloseBrackets
        case tooManyOpenBrackets
    }

    enum RuntimeError: Swift.Error {
        case invalidDataIndex(instructionIndex: Int)
        case invalidInstructionIndex(current: Int, proposedValue: Int)
    }
}

extension Interpreter: CustomStringConvertible {
     public var description: String {
        var instructions: String {
            self.instructions.map(String.init).joined(separator: " ")
        }

        var instructionPointer: String {
            String(repeating: " ", count: instructionIndex * 2) + "^"
        }

        var dataPointer: String {
            String(repeating: " ", count: 1 + dataIndex * 3) + "^"
        }

        var divider: String {
            String(repeating: "-", count: data.count * 3)
        }

        return """
        \(data)
        \(dataPointer)

        \(instructions)
        \(instructionPointer)

        \(divider)

        """
    }
}
