import DGis
import Foundation
import GGEnergy
import SwiftUI
import UIKit

/// Presents the host's existing picker. Complete once after dismissal;
/// nil means cancellation. Do not retain a presenting controller.
@MainActor
public protocol EnergyPaymentPicker: AnyObject {
    func show(from controller: UIViewController, onResult: @escaping (EnergyPaymentMethod?) -> Void)
}

public enum GGEnergySdkError: LocalizedError {
    case invalidBootstrapToken

    public var errorDescription: String? {
        switch self {
        case .invalidBootstrapToken:
            return "bootstrapToken must not be blank"
        }
    }
}

/// Selects who owns the 2GIS context. Both modes use the same FullSDK runtime.
public enum GGEnergyMapProvider {
    /// ggEnergy creates a container using its packaged map key.
    case sdkManaged

    /// Reuses the host's initialized FullSDK container and credentials.
    /// ggEnergy creates its own map factory/view and retains the container
    /// while its screen is open; it does not reuse or move the host's map view.
    case external(container: DGis.Container)
}

/// iOS partner API. The SDK owns the full-screen controller it presents.
@MainActor
public enum GGEnergySdk {
    public static var version: String { EnergySdk.shared.VERSION }

    public static func open(
        from presentingViewController: UIViewController,
        bootstrapToken: String,
        paymentPicker: EnergyPaymentPicker? = nil,
        mapProvider: GGEnergyMapProvider = .sdkManaged
    ) throws {
        let bootstrapToken = bootstrapToken.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !bootstrapToken.isEmpty else {
            throw GGEnergySdkError.invalidBootstrapToken
        }
#if DEBUG
        EnergyIosBridge.shared.setDebugNetworkLogging(enabled: true)
#else
        EnergyIosBridge.shared.setDebugNetworkLogging(enabled: false)
#endif

        let mapViewController: DgisMapViewController?
        switch mapProvider {
        case .sdkManaged:
            do {
                mapViewController = try DgisMapViewController.make()
            } catch {
#if DEBUG
                print("GGEnergySdk: 2GIS map is unavailable: \(error)")
#endif
                mapViewController = nil
            }
        case .external(let container):
            // Report an invalid host map configuration to the caller. Never
            // silently replace the host's credentials with the SDK's key.
            mapViewController = try DgisMapViewController.make(container: container)
        }

        let holder = WeakViewController()
        let picker: ((@escaping (EnergyPaymentMethod?) -> KotlinUnit) -> Void)? = paymentPicker.map { hostPicker in
            { result in
                guard let controller = holder.value else {
                    _ = result(nil)
                    return
                }
                hostPicker.show(from: controller) { payment in
                    _ = result(payment)
                }
            }
        }
        let composeViewController = EnergyIosBridge.shared.makeViewController(
            bootstrapToken: bootstrapToken,
            nativeMapViewController: mapViewController,
            nativeMap: mapViewController,
            resourcePath: Bundle.module.resourcePath!,
            paymentPicker: picker,
            onClose: {
                holder.value?.dismiss(animated: true)
            }
        )
        let sdkViewController = PortraitViewController(content: composeViewController)
        holder.value = sdkViewController
        sdkViewController.modalPresentationStyle = .fullScreen
        presentingViewController.present(sdkViewController, animated: true)
    }
}

@MainActor
private final class DgisMapViewController: UIViewController, @preconcurrency EnergyNativeMap {
    private let container: DGis.Container
    private let mapFactory: any IMapFactory
    private let hostingController: UIHostingController<AnyView>
    private var markers: IosStationMarkers?
    private let currentLocation = IosCurrentLocation()
    private var styleRequest: DGis.Cancellable?
    private var styleRequestId = 0

    func render(
        markers: [EnergyMapMarker],
        userLocation: MapUserLocation?,
        onStationTap: @escaping (KotlinLong) -> Void,
        onUserLocationChanged: @escaping (MapUserLocation?) -> Void
    ) {
        currentLocation.onLocation = { location in
            guard let location else {
                onUserLocationChanged(nil)
                return
            }
            onUserLocationChanged(MapUserLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        }
        self.markers?.render(markers, userLocation: userLocation, onStationTap: onStationTap)
    }

    func loadCurrentUserLocation() { currentLocation.loadIfAuthorized() }

    func requestCurrentUserLocation() { currentLocation.request() }

    func isLocationServiceEnabled() -> Bool { currentLocation.isLocationServiceEnabled }

    func showLocationServiceSettingsAlert(
        title: String,
        message: String,
        cancelLabel: String,
        settingsLabel: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: cancelLabel, style: .cancel))
        alert.addAction(UIAlertAction(title: settingsLabel, style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsUrl)
        })
        present(alert, animated: true)
    }

    func focusOnUserLocation(location: MapUserLocation) {
        _ = mapFactory.map.camera.move(
            position: CameraPosition(
                point: DGis.GeoPoint(
                    latitude: .init(value: location.latitude),
                    longitude: .init(value: location.longitude)
                ),
                zoom: Zoom(value: 15)
            ),
            time: 0.3
        )
    }

    func openNavigation(appId: String, latitude: Double, longitude: Double) {
        let destination: URL? = switch appId {
        case "comgooglemaps":
            URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving")
        case "mapsme":
            URL(string: "mapsme://map?v=1&ll=\(latitude),\(longitude)")
        case "yandexnavi":
            URL(string: "yandexnavi://build_route_on_map?lat_to=\(latitude)&lon_to=\(longitude)")
        case "waze":
            URL(string: "waze://?ll=\(latitude),\(longitude)&navigate=yes")
        case "dgis":
            URL(string: "dgis://2gis.ru/routeSearch/rsType/car/to/\(longitude),\(latitude)/go")
        default:
            nil
        }
        guard let destination else {
            openAppleMaps(latitude: latitude, longitude: longitude)
            return
        }
        UIApplication.shared.open(destination, options: [:]) { [weak self] opened in
            if !opened {
                self?.openAppleMaps(latitude: latitude, longitude: longitude)
            }
        }
    }

    private func openAppleMaps(latitude: Double, longitude: Double) {
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [URLQueryItem(name: "daddr", value: "\(latitude),\(longitude)")]
        if let url = components?.url { UIApplication.shared.open(url) }
    }

    static func make() throws -> DgisMapViewController {
        guard let keyPath = Bundle.module.path(
            forResource: "ggenergy-dgissdk",
            ofType: "key"
        ) else {
            throw DgisMapError.keyNotFound
        }

        let keySource = KeySource.fromFile(KeyFromFile(path: keyPath))
        let container = DGis.Container(keySource: keySource)
        return try make(container: container)
    }

    static func make(container: DGis.Container) throws -> DgisMapViewController {
        let mapFactory = try container.makeMapFactory(options: .default)
        _ = mapFactory.map.camera.move(
            position: CameraPosition(
                point: DGis.GeoPoint(
                    latitude: .init(value: 40.1772),
                    longitude: .init(value: 44.5035)
                ),
                zoom: Zoom(value: 13)
            ),
            time: 0
        )
        return try DgisMapViewController(container: container, mapFactory: mapFactory)
    }

    private init(container: DGis.Container, mapFactory: any IMapFactory) throws {
        self.container = container
        self.mapFactory = mapFactory
        self.hostingController = UIHostingController(
            rootView: AnyView(mapFactory.mapView.ignoresSafeArea())
        )
        super.init(nibName: nil, bundle: nil)
        markers = try IosStationMarkers(container: container, factory: mapFactory)
        hostingController.rootView = AnyView(markers!.mapView.ignoresSafeArea())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .energyBackground
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        applyMapStyle(for: traitCollection)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }
        applyMapStyle(for: traitCollection)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hostingController.view.frame = view.bounds
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed || parent?.isBeingDismissed == true {
            styleRequest?.cancel()
            styleRequest = nil
            markers?.close()
        }
    }

    private func applyMapStyle(for traits: UITraitCollection) {
        styleRequestId += 1
        let requestId = styleRequestId
        styleRequest?.cancel()
        markers?.apply(style: traits.userInterfaceStyle)

        let resourceName = traits.userInterfaceStyle == .dark ? MapStyle.darkResourceName : MapStyle.lightResourceName
        guard let styleUrl = Bundle.module.url(forResource: resourceName, withExtension: "2gis") else { return }

        do {
            let future = try container.styleFactory.loadFile(url: styleUrl)
            styleRequest = future.sinkOnMainThread(
                receiveValue: { [weak self] style in
                    MainActor.assumeIsolated {
                        guard let self, self.styleRequestId == requestId else { return }
                        self.mapFactory.map.style = style
                    }
                },
                failure: { _ in
                    // Keep the SDK default style when the packaged custom style cannot be loaded.
                },
            )
        } catch {
            // Keep the SDK default style when the style factory is unavailable.
        }
    }
}

private enum MapStyle {
    static let lightResourceName = "ggenergy_map_light"
    static let darkResourceName = "ggenergy_map_dark"
}

private extension UIColor {
    static let energyBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 38 / 255, green: 38 / 255, blue: 38 / 255, alpha: 1)
            : UIColor(red: 246 / 255, green: 247 / 255, blue: 247 / 255, alpha: 1)
    }
}

private enum DgisMapError: LocalizedError {
    case keyNotFound

    var errorDescription: String? {
        "The ggEnergy 2GIS key is missing from the SDK package."
    }
}

private final class WeakViewController {
    weak var value: UIViewController?
}

private final class PortraitViewController: UIViewController {
    private let content: UIViewController

    init(content: UIViewController) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .energyBackground
        addChild(content)
        view.addSubview(content.view)
        content.didMove(toParent: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        content.view.frame = view.bounds
    }
}
