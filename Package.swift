// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SoundManager",
    platforms: [
    .iOS(.v12),
    .watchOS(.v2),
    .macOS(.v10_10),
    .tvOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SoundManager",
            targets: ["SoundManager"]),
    ],
    targets: [
        .target(
            name: "SoundManager",
            dependencies: []),
        .testTarget(
            name: "SoundManagerTests",
            dependencies: ["SoundManager"]),
    ]
)
