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
            url: "https://github.com/gg-energy/gg-energy-sdk/releases/download/v0.1.7/GGEnergy-0.1.7.xcframework.zip",
            checksum: "15aaf155a685ba5bed35c5a3ebe9ec701476431830a67b9d8fbc870e4ee7467f"
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
