//
// Created by Eric Lightfoot on 2021-06-02.
//

import MapboxMaps
import CoreLocation

extension CameraOptions {
    init (cameraState state: CameraState,
            center: CLLocationCoordinate2D? = nil,
            padding: UIEdgeInsets? = nil,
            zoom: CGFloat? = nil,
            bearing: CLLocationDirection? = nil,
            pitch: CGFloat? = nil
    ) {
        self.init(
                center: center ?? state.center,
                padding: padding ?? state.padding,
                anchor: nil,
                zoom: zoom ?? state.zoom,
                bearing: bearing ?? state.bearing,
                pitch: pitch ?? state.pitch
        )
    }
}