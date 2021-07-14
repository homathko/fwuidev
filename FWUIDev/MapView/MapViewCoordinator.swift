//
// Created by Eric Lightfoot on 2021-06-01.
//

import UIKit
import MapboxMaps
import Combine
import Turf

/// Here's our custom `Coordinator` implementation.
internal class MapboxViewCoordinator: GestureManagerDelegate {

    var state = MapViewState.base

    /// It also has a setter for annotations. When the annotations
    /// are set, it synchronizes them to the map
    var annotations = [FWMapSprite]() {
        willSet {
            if newValue != annotations {
                syncAnnotations()
            }
        }
    }

    /// Use coordinator to hold previous value and guard
    var centerCoordinate: CLLocationCoordinate2D = .init()
    var bottomPadding: CGFloat = .zero

    var mapMoved: ([FWMapSprite]) -> () = { _ in }

    /// This `mapView` property needs to be weak because
    /// the map view takes a strong reference to the coordinator
    /// when we make the coordinator observe the `.cameraChanged`
    /// event
    weak var mapView: MapView? {
        didSet {
            /// The coordinator observes the `.cameraChanged` event, and
            /// whenever the camera changes, it updates the camera binding
            mapView?.mapboxMap.onEvery(.cameraChanged, handler: notify(for:))

            /// TODO
            /// The coordinator must monitor for gestures to tell
            /// SwiftUI that tracking mode may be changing

            /// The coordinator also observes the `.mapLoaded` event
            /// so that it can sync annotations whenever the map reloads
            mapView?.mapboxMap.onNext(.mapLoaded, handler: notify(for:))
        }
    }

    func notify (for event: MapboxMaps.Event) {
        guard let typedEvent = MapEvents.EventKind(rawValue: event.type),
              let mapView = mapView else {
            return
        }

        switch typedEvent {
            /// As the camera changes, we update the binding. SwiftUI
            /// will propagate this change to any other UI elements connected
            /// to the same binding.
            case .cameraChanged:
                parent?.controller.camera = MapCameraState(
                        center: mapView.cameraState.center,
                        heading: mapView.cameraState.bearing,
                        zoom: mapView.cameraState.zoom,
                        pitch: mapView.cameraState.pitch
                )
                syncSwiftUI()

            /// When the map reloads, we need to re-sync the annotations
            case .mapLoaded:
                initialMapLoadComplete = true
                mapView.gestures.delegate = self
                /// Immediately limit pitch angle due to 2D annotations
                let boundsOptions = CameraBoundsOptions(maxPitch: 24)
                try! mapView.mapboxMap.setCameraBounds(for: boundsOptions)
                syncAnnotations()
                syncMapState()

            default:
                break
        }
    }

    var parent: MapboxViewRepresentable?

    /// Only sync annotations once the map's initial load is complete
    private var initialMapLoadComplete = false

    private var annotationsManager: PointAnnotationManager?
    /// To sync annotations, we use the annotations' identifiers to determine which
    /// annotations need to be added and which ones need to be removed.
    private func syncAnnotations () {
        guard let mapView = mapView, initialMapLoadComplete else {
            return
        }

        let annotationsManager = annotationsManager ?? mapView.annotations.makePointAnnotationManager()
        annotationsManager.syncAnnotations(annotations.map {
            PointAnnotation(coordinate: $0.location.coordinate)
        })
        self.annotationsManager = annotationsManager

        /// Here is the other call site for sending updated map sprite models back to SwiftUI
        /// (eg when an annotation moves but the camera doesn't)
        syncSwiftUI()
    }

    /// Modify mapView according to MapViewState
    func syncMapState () {
        guard let mapView = mapView,
              initialMapLoadComplete else {
            return
        }

        /// Update gesture availability according to updated constraints
        enableGestures(forState: state)

        let insets = UIEdgeInsets(top: 30, left: 30, bottom: bottomPadding + 30, right: 30)
        /// Limit map zoom out
        let maxHeight = UIScreen.main.bounds.height * 0.65
        let newCamera = camera(forState: state, padding: insets.maximumHeight(maxHeight))
//        mapView.camera.ease(to: newCamera, duration: state == .gesturing ? 0 : 1.0)
        mapView.camera.ease(to: newCamera, duration: 0)
    }

    func syncSwiftUI () {
        if let mapView = mapView {
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                let updated = self?.annotations.compactMap { sprite -> FWMapSprite? in
                    var result = sprite
                    result.point = mapView.mapboxMap.point(for: sprite.location.coordinate)
                    if mapView.frame.contains(result.point!) {
                        return result
                    } else {
                        return nil
                    }
                }

                DispatchQueue.main.async { [weak self] in
                    self?.mapMoved(updated ?? [])
                }
            }
        }
    }

    func gestureBegan (for gestureType: GestureType) {
        parent?.controller.state = .gesturing
    }
}
