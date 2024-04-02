// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RequestService",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "RequestService",
            targets: ["RequestService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0"))
    ],
    targets: [
        .target(
            name: "RequestService",
            dependencies: [   
                .product(name: "Moya", package: "Moya"),
                .product(name: "CombineMoya", package: "Moya")]),
        .testTarget(
            name: "RequestServiceTests",
            dependencies: ["RequestService"]),
    ]
)
