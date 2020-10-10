//swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwiftAudio",
    products: [
        .library(
            name: "SwiftAudio",
            targets: ["SwiftAudio"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftAudio",
            dependencies: [],
            path: "SwiftAudio/Classes")
    ]
)
