// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "stumpy",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/sbeitzel/stumpylib.git", from: "1.1.3"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.2")
    ],
    targets: [
        .executableTarget(
            name: "stumpy",
            dependencies: [
                .product(name: "stumpylib", package: "stumpylib"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ])
    ]
)
