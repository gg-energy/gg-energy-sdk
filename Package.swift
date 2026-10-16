// swift-tools-version: 6.0
import PackageDescription

// The iOS face of sdk-energy. `ios-main` depends on this, never on the
// XCFramework directly, so hosts never import Compose or Kotlin build artifacts
// by hand.
//
// Both SDK-managed and host-container map modes use this one product. Hosts
// already using FullSDK must use the same package identity and a compatible
// version so SwiftPM resolves one DGis runtime for the application.
let package = Package(
    name: "GGEnergyKit",
    platforms: [
        // Matches ios-main/Packages/Design.
        .iOS(.v16)
    ],
    products: [
        .library(name: "GGEnergyKit", targets: ["GGEnergyKit"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/2gis/mobile-sdk-full-swift-package.git",
            from: "13.6.0"
        )
    ],
    targets: [
        // Staged by `./gradlew :sdk:stageSwiftPackage` before the complete
        // package is archived as a versioned GitHub Release asset.
        .binaryTarget(
            name: "GGEnergy",
            url: "https://github.com/gg-energy/gg-energy-sdk/releases/download/v0.2.0/GGEnergy-0.2.0.xcframework.zip",
            checksum: "b949e1f74f016c396360155ee733b16f3295983e08f7161b71526d58b93c13fd"
        ),
        .target(
            name: "GGEnergyKit",
            dependencies: [
                "GGEnergy",
                .product(name: "FullSDK", package: "mobile-sdk-full-swift-package"),
            ],
            resources: [
                // The SDK-managed 2GIS key is part of the distributed package.
                // Its redistribution and partner-app scope require release approval.
                .copy("Resources/ggenergy-dgissdk.key"),
                .copy("Resources/ggenergy_map_light.2gis"),
                .copy("Resources/ggenergy_map_dark.2gis"),
                .copy("Resources/composeResources"),
            ]
        ),
    ]
)
