//
// Created by Eric Lightfoot on 2021-06-01.
//

import UIKit
import MapboxMaps
import Combine
import Turf

/// Here's our custom `Coordinator` implementation.
@available(iOS 13.0, *)
internal class MapboxViewCoordinator {

    /// It holds a binding to the camera
    var state = MapViewState() {
        didSet {
            syncMapState()
        }
    }

    /// It also has a setter for annotations. When the annotations
    /// are set, it synchronizes them to the map
    var annotations = [FWMapSpriteContract]() {
        didSet {
            syncAnnotations()
        }
    }

    var insets: UIEdgeInsets = .zero
    var mapMoved: (MapboxViewCoordinator) -> () = { _ in }

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

    func notify (for event: Event) {
        guard let typedEvent = MapEvents.EventKind(rawValue: event.type),
              let mapView = mapView else {
            return
        }
        switch typedEvent {
            /// As the camera changes, we update the binding. SwiftUI
            /// will propagate this change to any other UI elements connected
            /// to the same binding.
            case .cameraChanged:
                state.shouldUpdateView = false
                mapMoved(self)

            /// When the map reloads, we need to re-sync the annotations
            case .mapLoaded:
                initialMapLoadComplete = true
                syncAnnotations()

            default:
                break
        }
    }

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
        annotationsManager.syncAnnotations(annotations.map { PointAnnotation(coordinate: $0.location.coordinate) })
        self.annotationsManager = annotationsManager
//        let annotationsByIdentifier = Dictionary(uniqueKeysWithValues: annotations.map {
//            ($0.id, $0)
//        })
//
//        let oldAnnotationIds = Set(mapView.annotations.annotations.values.map(\.identifier))
//        let newAnnotationIds = Set(annotationsByIdentifier.values.map(\.identifier))
//
//        let idsForAnnotationsToRemove = oldAnnotationIds.subtracting(newAnnotationIds)
//        let annotationsToRemove = idsForAnnotationsToRemove.compactMap {
//            mapView.annotations.annotations[$0]
//        }
//        if !annotationsToRemove.isEmpty {
//            mapView.annotations.removeAnnotations(annotationsToRemove)
//        }
//
//        let idsForAnnotationsToAdd = newAnnotationIds.subtracting(oldAnnotationIds)
//        let annotationsToAdd = idsForAnnotationsToAdd.compactMap {
//            annotationsByIdentifier[$0]
//        }
//        if !annotationsToAdd.isEmpty {
//            mapView.annotations.addAnnotations(annotationsToAdd)
//        }
    }

    /// Modify mapView according to MapViewState
    private func syncMapState () {
        guard let mapView = mapView,
              initialMapLoadComplete else {
            return
        }

        /// Update gesture availability according to updated constraints
        enableGestures(forState: state)

        let newCamera = camera(forState: state, padding: insets)
        mapView.camera.ease(to: newCamera, duration: state.easeSpeed)
    }
}
