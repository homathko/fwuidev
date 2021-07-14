//
// Created by Eric Lightfoot on 2021-06-01.
//

import MapboxMaps
import Turf

extension MapboxViewCoordinator {
    internal func enableGestures (forState state: MapViewState) {
        guard let mapView = mapView else {
            return
        }
        let reducedOnlyOncePlease = state.constraints() /// <<< derived data
        if case .pan(_, let canOverride) = reducedOnlyOncePlease.pan {
            mapView.gestures.options.scrollEnabled = canOverride
        }
        if case .zoom(let zoom, let canOverride) = reducedOnlyOncePlease.zoom {
            mapView.gestures.options.zoomEnabled = canOverride
            if canOverride {
                try! mapView.mapboxMap.setCameraBounds(for: CameraBoundsOptions(maxZoom: CGFloat(zoom + 2)))
            }
        }
        if case .heading(_, let canOverride) = reducedOnlyOncePlease.heading {
            mapView.gestures.options.rotateEnabled = canOverride
        }
        if case .pitch(_, let canOverride) = reducedOnlyOncePlease.pitch {
            mapView.gestures.options.pitchEnabled = canOverride
        }
    }

    internal func camera (forState state: MapViewState, padding: UIEdgeInsets = .zero) -> CameraOptions {
        guard let mapView = mapView else {
            return CameraOptions()
        }

        let cameraState = mapView.cameraState

        let focused = state.focusing()
        /// With no focus, camera options should not be modified
        if focused.count == 0 {
            return CameraOptions(cameraState: cameraState, padding: padding)
        }
            /// With a single focii, previous camera zoom factor could
            /// be used if not specified in a constraint
//        else if focused.count == 1 {
//            var nextZoom: CGFloat = 0.0
//            if let zoom = state.constraints().zoom {
//                /// There is a specified zoom constraint
//                if case .zoom(let value, _) = zoom {
//                    nextZoom = CGFloat(value)
//                }
//            } else {
//                /// No constraint, use previous
//                nextZoom = mapView.cameraState.zoom
//            }
//
//            nextZoom = max(6, mapView.cameraState.zoom)
//            nextZoom = min(10, mapView.cameraState.zoom)
//
//            return CameraOptions(
//                    cameraState: cameraState,
//                    center: focused.first!.location.coordinate,
//                    padding: padding,
//                    zoom: nextZoom
//            )
//        }

        /// With many focii, zoom should be set to fit them "comfortably"
        /// (padded) but zooming farther away should be allowed if
        /// the constraint is overridable
        else if focused.count >= 1 {
            var camera = mapView.mapboxMap.camera(
                for: Geometry.polygon(Polygon([
                    state.focusing().map {
                        $0.location.coordinate
                    }
                ])),
                padding: padding,
                bearing: state.constraints().heading?.headingValue(),
                pitch: min(15, mapView.cameraState.pitch)
            )

            let maxZoom: CGFloat = 12.0
            let nextZoom = min(state.constraints().zoom?.zoomValue() ?? maxZoom, maxZoom)
            let boundsOptions = CameraBoundsOptions(maxZoom: nextZoom, maxPitch: 24)
            try! mapView.mapboxMap.setCameraBounds(for: boundsOptions)

            return camera
        } else {
            return CameraOptions(center: cameraState.center)
        }
    }
}

extension UIEdgeInsets {
    func maximumHeight (_ height: CGFloat) -> UIEdgeInsets {
        .init(
            top: self.top,
            left: self.left,
            bottom: min(self.bottom, height),
            right: self.right
          )
    }
}