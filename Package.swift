// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "YMOverride",
    platforms: [
        .iOS(.v10),
        .tvOS(.v10),
    ],
    products: [
        .library(
            name: "YMOverride",
            targets: ["YMOverride"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "YMOverride",
            path: "Source",
            exclude: [
                "TestSupport"
            ]),
    ]
)
