// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "VaporProject",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.3.0")),
        .package(url: "https://github.com/vapor/leaf-provider.git", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/vapor/postgresql-provider.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/nodes-vapor/slugify.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "LeafProvider", "FluentProvider", "PostgreSQLProvider", "Slugify"],
            exclude: [
                "Config",
                "Database",
                "Localization",
                "Public",
                "Resources",
            ]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
        .target(name: "Run", dependencies: ["App"])
    ]
)

