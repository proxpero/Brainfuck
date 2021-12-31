// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Brainfuck",
    products: [
        .library(
            name: "Brainfuck",
            targets: ["Brainfuck"]
        ),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "cli",
            dependencies: ["Brainfuck"]
        ),
        .target(
            name: "Brainfuck",
            dependencies: []
        ),
        .testTarget(
            name: "BrainfuckTests",
            dependencies: ["Brainfuck"]
        ),
    ]
)
