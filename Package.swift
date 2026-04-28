// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SitStandTracker",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "SitStandTracker",
            targets: ["SitStandTracker"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "SitStandTracker"
        ),
    ]
)
