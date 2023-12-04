# Utility

Utility package.

## Intoroduction

[Swift Package Manager](https://www.swift.org/package-manager/) is supported.

### Into Project

add package into `Package Dependencies`

### Into Package

```swift
let package = Package(
    name: "Sample",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "Sample",
            targets: ["Sample"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/miyoshitakaaki/swift-architecture-template-utility",
            .upToNextMajor(from: "1.0.0")
        ),
    ],
    targets: [
        .target(
            name: "Sample",
            dependencies: [
                .product(name: "Utility", package: "swift-architecture-template-utility"),
            ]
        ),
        .testTarget(
            name: "SampleTests",
            dependencies: ["Sample"]
        ),
    ]
)
```

### Usage

`import Utility`

## Requirements

- Xcode 15.x or later
- iOS 13 or later

## Documentation

- [Use APIClient](https://miyoshitakaaki.github.io/swift-architecture-template-utility/documentation/utility/usageofapiclient/)
- [Use Usecase](https://miyoshitakaaki.github.io/swift-architecture-template-utility/documentation/utility/useusecase/)

## Generate Docs
- `make` or `make create_doc`

## Code Format

`swiftformat .`

## Versioning

[Semantic Versioning](https://semver.org/)
