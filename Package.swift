// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "alerts-and-pickers",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "alerts-and-pickers",
            targets: ["alerts-and-pickers"])
    ],
    targets: [
        .target(name: "alerts-and-pickers", 
                path: "Source")
    ]
)
