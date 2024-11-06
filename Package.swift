// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DOTNArmillarySolver",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DOTNArmillarySolver",
            targets: ["DOTNArmillarySolver"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/michael94ellis/SwiftUIJoystick", branch: "main"),
        .package(url: "https://github.com/lucaszischka/BottomSheet", branch: "main"),
        .package(url: "https://github.com/NiccoloBargioni/ZTronProblemSolver", branch: "main"),
        .package(url: "https://github.com/NiccoloBargioni/ZTronCarouselCore", branch: "main"),
        .package(url: "https://github.com/joehinkle11/Lazy-View-SwiftUI", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DOTNArmillarySolver",
            dependencies: [
                .product(name: "SwiftUIJoystick", package: "SwiftUIJoystick"),
                .product(name: "BottomSheet", package: "BottomSheet"),
                .product(name: "ZTronProblemSolver", package: "ZTronProblemSolver"),
                .product(name: "ZTronCarouselCore", package: "ZTronCarouselCore"),
                .product(name: "LazyViewSwiftUI", package: "Lazy-View-SwiftUI"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=complete")
            ]
        ),
        .testTarget(
            name: "DOTNArmillarySolverTests",
            dependencies: ["DOTNArmillarySolver"]
        ),
    ]
)
