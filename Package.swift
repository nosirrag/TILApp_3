// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TILApp_3",
    dependencies: [
        
    // Vapor
    .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc"),
    
    // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
    
    // Fluent PostgreSQL
    .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc"),

    // Leaf
    .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0")
    
    ],
    targets: [
    // 2
    .target(name: "App", dependencies: ["FluentPostgreSQL",
    "Vapor", "FluentSQLite", "Leaf"]),
    .target(name: "Run", dependencies: ["App"]),
    .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
