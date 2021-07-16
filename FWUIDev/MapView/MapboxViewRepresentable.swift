import Foundation
import UIKit
import MapboxMaps
import Turf
import SwiftUI

extension StyleURI {
    static let myStyle = StyleURI(rawValue: "mapbox://styles/htek/ck3rpnd7i1ddp1cp7nn6m2q3x")!
}

/// `SwiftUIMapView` is a SwiftUI wrapper around UIKit-based `MapView`.
/// It works by conforming to the `UIViewRepresentable` protocol. When
/// your app uses `SwiftUIMapView`, SwiftUI creates and manages a
/// single instance of `MapView` behind the scenes so that if your map
/// configuration changes, the underlying map view doesn't need to be recreated.
@available(iOS 13.0, *)
struct MapboxViewRepresentable: UIViewRepresentable {
    /// Bindings should be used for map values that can
    /// change as a result of user interaction. They allow
    /// other UI elements to stay in sync as the user interacts
    /// with the map.

    @ObservedObject var controller: MapController

    @Binding var cardTop: CGFloat
    var bottomInset: CGFloat

    /// Update parent view when camera changes, etc
    var mapMoved: ([FWMapSprite]) -> () = { _ in }

    /// Map attributes that can only be configured programmatically
    /// can simply be exposed as a private var paired with a
    /// builder-style method. When you use `SwiftUIMapView`, you
    /// have the option to customize it by calling the builder method.
    /// For example, with `styleURI`, you might say
    var styleURI = StyleURI.streets

    /// This is the builder-style method for setting `styleURI`.
    /// It returns an updated `SwiftUIMapView` value that
    /// has the specified `styleURI`. This approach allows you
    /// to chain these customizers — a common pattern in SwiftUI.
    func styleURI (_ styleURI: StyleURI) -> Self {
        var updated = self
        updated.styleURI = styleURI
        return updated
    }

    /// Here's a property and builder method for annotations
    var annotations = [FWMapSprite]()

    func annotations (_ annotations: [FWMapSprite]) -> Self {
        var updated = self
        updated.annotations = annotations
        return updated
    }

    let mapInitOptions = MapInitOptions(
            resourceOptions: ResourceOptionsManager(
                    accessToken: "pk.eyJ1IjoiaHRlayIsImEiOiJja2gyZDB4Z3IwYW90MnNucHZ6aTN2N2g5In0.qOxZe7m1td1XTWkyIZCW-A"
            ).resourceOptions,
            cameraOptions: CameraOptions(center: .squamish, zoom: 4)
    )

    /// The first time SwiftUI needs to render this view, it starts by invoking `makeCoordinator()`.
    /// SwiftUI holds on to the value you return just like it holds on to the `MapView`. This gives you a
    /// place to direct callbacks from the MapView (delegates, observer callbacks, etc). You need to
    /// use the coordinator for this and not this struct because this struct can be recreated many times
    /// as your map configurations change externally. Fortunately, even as this struct is recreated,
    /// the coordinator and the map view will only be created once.
    func makeCoordinator () -> MapboxViewCoordinator {
        MapboxViewCoordinator()
    }

    /// After SwiftUI creates the coordinator, it creates the underlying `UIView`, in this case a `MapView`.
    /// This method should create the `MapView`, and make sure that it is configured to be in sync
    /// with the current settings of `SwiftUIMapView` (in this example, just the `camera` and `styleURI`).
    func makeUIView (context: UIViewRepresentableContext<MapboxViewRepresentable>) -> MapView {
        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        /// Defer add 3D terrain until after style is loaded
        mapView.mapboxMap.onNext(.styleLoaded) { _ in
            // Add terrain
            var demSource = RasterDemSource()
            demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
            demSource.tileSize = 512
            demSource.maxzoom = 14.0

            do {
                try mapView.mapboxMap.style.addSource(demSource, id: "mapbox-dem")
            } catch (let err) {
                dump(err)
            }

            var terrain = Terrain(sourceId: "mapbox-dem")
            terrain.exaggeration = .constant(1.0)

            // Add sky layer
            try! mapView.mapboxMap.style.setTerrain(terrain)

            var skyLayer = SkyLayer(id: "sky-layer")
            skyLayer.skyType = .constant(.gradient)
            skyLayer.skyAtmosphereSun = .constant([0.0, 0.0])
            skyLayer.skyAtmosphereSunIntensity = .constant(5.0)

            try! mapView.mapboxMap.style.addLayer(skyLayer)

            /// This built-in solution doesn't jive with the FWMapSprite set up
//            mapView.location.options.puckType = .puck2D()
        }

//        updateUIView(mapView, context: context)

        /// Additionally, this is your opportunity to connect the coordinator to the map view. In this example
        /// the coordinator is given a reference to the map view. It uses the reference to set up the necessary
        /// observations so that it can respond to map events.
        context.coordinator.mapView = mapView

        /// Get updated positions of visible sprites from coordinator
        /// and set binding in MapboxView
        context.coordinator.mapMoved = mapMoved

        /// MapCoordinator will need to be able
        /// to use controller
        context.coordinator.parent = self

        return mapView
    }

    /// If your `SwiftUIMapView` is reconfigured externally, SwiftUI will invoke `updateUIView(_:context:)`
    /// to give you an opportunity to re-sync the state of the underlying map view.
    func updateUIView (_ mapView: MapView, context: Context) {
        /// Since changing the style causes annotations to be removed from the map
        /// we only call the setter if the value has changed.
        if mapView.mapboxMap.style.uri != styleURI {
            mapView.mapboxMap.style.uri = styleURI
        }

        /// The coordinator needs to manage annotations because
        /// they need to be applied *after* `.mapLoaded`
        context.coordinator.annotations = annotations

        let bottomPadding = UIScreen.main.bounds.height - cardTop - bottomInset - 40 /// < -20 is handleHeight defined in FWCardView
        var syncFlag = false
        if bottomPadding != context.coordinator.bottomPadding {
            context.coordinator.bottomPadding = bottomPadding
            syncFlag = true
        }

        if context.coordinator.state != controller.state {
//            print("MapViewState change -> \(controller.state)")
            context.coordinator.state = controller.state
            syncFlag = true
        }

        if syncFlag { context.coordinator.syncMapState() }
    }
}