// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swift-website",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Website",
            targets: ["Website"]
        ),
        .library(
            name: "Web",
            targets: ["Web"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.6.4"),
        .package(url: "https://github.com/pelagornis/swift-file", from: "1.3.1"),
        .package(url: "https://github.com/pelagornis/swift-command", from: "1.3.1")
    ],
    targets: [
        .executableTarget(
            name: "Website",
            dependencies: [
                .target(name: "Web"),
                .target(name: "Generator")
            ],
            exclude: [
                "Styles/global.css"
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "Web",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "Generator",
            dependencies: [
                .product(name: "Command", package: "swift-command"),
                .product(name: "File", package: "swift-file"),
                .product(name: "Logging", package: "swift-log"),
                .target(name: "Web")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
    ]
)
