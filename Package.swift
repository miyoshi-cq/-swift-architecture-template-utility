// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Utility",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_12),
    ],
    products: [
        .library(
            name: "Utility",
            targets: ["Utility"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Utility",
            dependencies: []
        ),
        .testTarget(
            name: "UtilityTests",
            dependencies: ["Utility"]
        ),
    ]
)
