// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AWPageControl",
    platforms: [.macOS(.v10_13)],
    products: [
        .library(
            name: "AWPageControl",
            targets: ["AWPageControl"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AWPageControl",
            dependencies: [],
            publicHeadersPath: "."
        )
    ]
)
