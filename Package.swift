// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "recommender",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "Recommender", targets: ["Recommender"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0")    
    ],
    targets: [
        .target(name: "Recommender", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "Vapor", package: "vapor")
        ]),
        .testTarget(name: "RecommenderTests", dependencies: [
            .target(name: "Recommender"),
        ])
    ]
)
