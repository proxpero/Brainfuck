import Foundation

public enum Brainfuck {
    public static func main(_ args: [String]) throws {
        if args.dropFirst().isEmpty {
            try runPrompt()
            return
        }

        if let path = args.dropFirst().first {
            try runFile(path)
            return
        }

        print("Usage: bf [script]")
        exit(64)
    }
}

extension Brainfuck {
    static func runFile(_ path: String) throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let source = String(decoding: data, as: UTF8.self)
        try run(source: source)
    }

    static func runPrompt() throws {
        while true {
            print("> ", terminator: "")
            guard let line = readLine() else { return }
            try run(source: line)
        }
    }

    static func run(source: String) throws {
        typealias Byte = UInt8
        var interpreter = try Interpreter<Byte>(source)
        try interpreter.run()
        if interpreter.hasOutput {
            print(interpreter.output)
        }
    }
}
