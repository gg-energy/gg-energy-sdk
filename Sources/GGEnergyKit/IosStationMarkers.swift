import DGis
import GGEnergy
import UIKit

@MainActor
final class IosStationMarkers {
    private let container: DGis.Container
    private let factory: any IMapFactory
    // Mutable because the pin, cluster and their colours are rebuilt when the
    // interface style flips; the whole type is @MainActor, so this stays safe.
    private var manager: MapObjectManager
    private let userLocationManager: MapObjectManager
    private var fastStationIcon: DGis.Image
    private var stationIcon: DGis.Image
    // The location dot has no black or white to swap: a blue core in a white
    // ring reads on both styles, and iOS and Android both leave it alone.
    private let userLocationIcon: DGis.Image
    private var style: UIUserInterfaceStyle = .light
    private var lastMarkers: [EnergyMapMarker] = []
    private var lastUserLocation: MapUserLocation?
    private var onStationTap: ((KotlinLong) -> Void)?
    private var callback: MapObjectTappedCallback?
    private(set) var mapView: DGis.MapView

    init(container: DGis.Container, factory: any IMapFactory) throws {
        self.container = container
        self.factory = factory
        mapView = factory.mapView
        let imageFactory = try container.imageFactory
        let palette = MarkerPalette.forStyle(.light)
        fastStationIcon = imageFactory.make(image: stationPin(palette: palette))
        stationIcon = imageFactory.make(image: standardStationPin(palette: palette))
        userLocationIcon = imageFactory.make(image: userLocationPin())
        userLocationManager = MapObjectManager(map: factory.map)
        manager = .withClustering(map: factory.map, logicalPixel: LogicalPixel(value: 36),
            maxZoom: Zoom(value: 13), clusterRenderer: StationClusterRenderer(
                icon: imageFactory.make(image: clusterCircle(palette: palette)),
                textColor: palette.content))
        let callback = MapObjectTappedCallback { [weak self] info in
            if let marker = info.item.item as? Marker, let id = marker.userData as? Int64 {
                Task { @MainActor [weak self] in self?.onStationTap?(KotlinLong(value: id)) }
            } else if let cluster = info.item.item as? SimpleClusterObject {
                let latitude = cluster.position.latitude.value
                let longitude = cluster.position.longitude.value
                Task { @MainActor [weak self] in
                    _ = self?.factory.map.camera.move(position: CameraPosition(point: GeoPoint(latitude: Latitude(value: latitude), longitude: Longitude(value: longitude)),
                        zoom: Zoom(value: 14)), time: 0.3)
                }
            }
        }
        self.callback = callback
        mapView = mapView.objectTappedCallback(callback: callback)
    }

    /// Rebuilds the marker artwork for a new interface style. The icons are
    /// baked into each marker, so the objects are laid out again afterwards.
    func apply(style: UIUserInterfaceStyle) {
        let resolved: UIUserInterfaceStyle = style == .dark ? .dark : .light
        guard resolved != self.style else { return }
        self.style = resolved
        guard let imageFactory = try? container.imageFactory else { return }
        let palette = MarkerPalette.forStyle(resolved)
        fastStationIcon = imageFactory.make(image: stationPin(palette: palette))
        stationIcon = imageFactory.make(image: standardStationPin(palette: palette))
        // The cluster icon and its label colour live in the renderer the
        // manager was created with, so the manager is rebuilt rather than mutated.
        manager.removeAll()
        manager = .withClustering(map: factory.map, logicalPixel: LogicalPixel(value: 36),
            maxZoom: Zoom(value: 13), clusterRenderer: StationClusterRenderer(
                icon: imageFactory.make(image: clusterCircle(palette: palette)),
                textColor: palette.content))
        draw()
    }

    func render(
        _ markers: [EnergyMapMarker],
        userLocation: MapUserLocation?,
        onStationTap: @escaping (KotlinLong) -> Void
    ) {
        self.onStationTap = onStationTap
        lastMarkers = markers
        lastUserLocation = userLocation
        draw()
    }

    private func draw() {
        let markers = lastMarkers
        let userLocation = lastUserLocation
        manager.removeAll()
        for item in markers {
            guard let marker = try? Marker(options: MarkerOptions(position: GeoPointWithElevation(
                latitude: Latitude(value: item.latitude), longitude: Longitude(value: item.longitude)),
                icon: item.fastCharging ? fastStationIcon : stationIcon,
                userData: item.id)) else { continue }
            manager.addObject(item: marker)
        }
        userLocationManager.removeAll()
        if let userLocation,
           let marker = try? Marker(options: MarkerOptions(
               position: GeoPointWithElevation(
                   latitude: Latitude(value: userLocation.latitude),
                   longitude: Longitude(value: userLocation.longitude)
               ),
               icon: userLocationIcon,
               zIndex: ZIndex(value: 1_000)
           )) {
            userLocationManager.addObject(item: marker)
        }
    }

    func close() {
        if let callback { mapView = mapView.removeObjectTappedCallback(callback: callback) }
        callback = nil
        onStationTap = nil
        lastMarkers = []
        lastUserLocation = nil
        manager.removeAll()
        userLocationManager.removeAll()
    }
}

private final class StationClusterRenderer: SimpleClusterRenderer {
    let icon: DGis.Image
    let textColor: UIColor
    init(icon: DGis.Image, textColor: UIColor) {
        self.icon = icon
        self.textColor = textColor
    }
    func renderCluster(cluster: SimpleClusterObject) -> SimpleClusterOptions {
        SimpleClusterOptions(icon: icon, text: String(cluster.objectCount),
            textStyle: TextStyle(fontSize: LogicalPixel(value: 16), color: DGis.Color(textColor)!,
                textPlacement: .centerCenter, suppressOnOverlap: false),
            zIndex: ZIndex(value: 6 + cluster.objectCount * 1000), animatedAppearance: true)
    }
}

private func clusterCircle(palette: MarkerPalette) -> UIImage {
    UIGraphicsImageRenderer(size: CGSize(width: 36, height: 36)).image { context in
        context.cgContext.setShadow(offset: CGSize(width: 0, height: 3), blur: 3,
            color: UIColor.black.withAlphaComponent(0.25).cgColor)
        palette.content.setFill()
        UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 36, height: 36)).fill()
        context.cgContext.setShadow(offset: .zero, blur: 0, color: nil)
        palette.fill.setFill()
        UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: 32, height: 32)).fill()
    }
}
