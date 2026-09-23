# iOS integration

The iOS SDK is provided as `GGEnergyKit`, a Swift package that wraps the
ggEnergy binary framework and its required map resources. It supports iOS 16
and later and presents the SDK full-screen over your view controller.

## 1. Add the released package

Download [GGEnergyKit-0.1.5.zip](https://github.com/gg-energy/gg-energy-sdk/releases/download/v0.1.5/GGEnergyKit-0.1.5.zip)
from the [0.1.5 release](https://github.com/gg-energy/gg-energy-sdk/releases/tag/v0.1.5)
along with its `.sha256` file. Verify the archive, then unzip it:

```sh
shasum -a 256 -c GGEnergyKit-0.1.5.zip.sha256
```

In Xcode, add the unzipped directory containing `Package.swift`
as a **local Swift package**, then link the `GGEnergyKit` product to your app.
Keep that exact archive in your dependency store so CI and other developers
build with the same SDK version.

The GitHub repository contains documentation and release assets, not a
repository-root Swift package. Do not enter this repository URL in Xcode's
remote package field. Ask [info@goenergy.am](mailto:info@goenergy.am) for
partner credentials and platform configuration.

## 2. Check host requirements

Use the **GGEnergyKit** product for both map modes below. The package declares
2GIS **FullSDK** (`mobile-sdk-full-swift-package`) starting at version **13.6.0**
and below 14.0.0. If your app already uses that package, its version requirement
must overlap this range so Swift Package Manager can resolve one shared runtime.
Do not embed another `DGis.xcframework` manually.

2GIS MapSDK and FullSDK cannot be linked into the same app. If your app uses
MapSDK, a manually embedded framework, or an incompatible FullSDK version,
contact [info@goenergy.am](mailto:info@goenergy.am) before integrating.
The external-container mode does not remove the FullSDK package dependency.

Add a location usage description to the host app's `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to show your position and nearby charging stations.</string>
```

## 3. Open the SDK with the included map setup

After your backend returns a fresh bootstrap token, present the SDK from a
`UIViewController`:

```swift
import GGEnergyKit

try GGEnergySdk.open(
    from: viewController,
    bootstrapToken: bootstrapToken
)
```

This is the default `mapProvider: .sdkManaged` mode. ggEnergy creates its own
2GIS container. No separate 2GIS setup is needed in your app.

## Reuse your app's 2GIS container

If your app already initializes a compatible FullSDK container, pass that same
instance when opening ggEnergy:

```swift
import DGis
import GGEnergyKit
import UIKit

@MainActor
func openEnergy(
    from viewController: UIViewController,
    bootstrapToken: String,
    hostContainer: DGis.Container
) throws {
    try GGEnergySdk.open(
        from: viewController,
        bootstrapToken: bootstrapToken,
        mapProvider: .external(container: hostContainer)
    )
}
```

Your container supplies the 2GIS configuration and must permit map rendering in
your host app. ggEnergy retains it while the screen is open and creates a
separate map view; your app's existing map view and camera remain yours.
Map initialization errors are thrown to your caller, without falling back to
the SDK-managed map configuration. Both modes use the same ggEnergy backend
bootstrap-token flow and the same `GGEnergyKit` product.

The SDK owns presentation and dismissal. Do not embed its view inside another
container. If you use an optional host payment picker, ensure every dismissal
path calls the completion handler exactly once; pass `nil` for cancellation.
