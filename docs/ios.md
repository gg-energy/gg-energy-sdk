# iOS integration

Add **GGEnergyKit** with Swift Package Manager (SPM). Requires **iOS 16 or later**.

## 1. Add the Swift package

In Xcode, choose **File → Add Package Dependencies** and enter:

```text
https://github.com/gg-energy/gg-energy-sdk.git
```

Choose **Exact Version: 0.1.7**, then add **GGEnergyKit** to your app target.
Xcode downloads the SDK and verifies its checksum automatically.
Commit `Package.resolved` to keep your team's dependency versions consistent.

If your app already uses 2GIS, check [compatibility](#apps-that-already-use-2gis) first.

## 2. Allow location access

Add this to your app's `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to show your position and nearby charging stations.</string>
```

## 3. Open Energy

Have your backend [create a fresh bootstrap token](backend-integration.md).
Keep partner credentials on your backend. On the main thread, open Energy
from your `UIViewController`:

```swift
import GGEnergyKit

try GGEnergySdk.open(
    from: viewController,
    bootstrapToken: bootstrapToken
)
```

The SDK opens full-screen and sets up the map automatically.
Request a new token for every launch; do not store or log it.

## Apps that already use 2GIS

GGEnergyKit requires 2GIS **FullSDK 13.6.0 or later, below 14.0.0**.
Your app's version requirement must overlap this range. Do not manually embed
a second `DGis.xcframework` or combine 2GIS MapSDK with FullSDK.
If your setup is incompatible, contact [info@goenergy.am](mailto:info@goenergy.am).
Using your own container still requires the FullSDK package dependency.

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

## Local dependencies on request

Contact [info@goenergy.am](mailto:info@goenergy.am) for a local integration package.
The release also includes [GGEnergyKit-0.1.7.zip](https://github.com/gg-energy/gg-energy-sdk/releases/download/v0.1.7/GGEnergyKit-0.1.7.zip)
and its [checksum file](https://github.com/gg-energy/gg-energy-sdk/releases/download/v0.1.7/GGEnergyKit-0.1.7.zip.sha256).
Download both to the same folder, then verify and extract:

```sh
shasum -a 256 -c GGEnergyKit-0.1.7.zip.sha256
unzip GGEnergyKit-0.1.7.zip
```

In Xcode, add the extracted folder containing `Package.swift` as a local package
and select **GGEnergyKit**.
This archive includes ggEnergy locally but downloads 2GIS remotely.
For fully local dependencies, request a package with compatible map dependencies
and approved redistribution terms.
