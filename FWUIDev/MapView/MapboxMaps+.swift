//
// Created by Eric Lightfoot on 2021-06-04.
//

import MapboxMaps


extension CoordinateBounds {
    func contains (_ coordinate: CLLocationCoordinate2D) -> Bool {

        let lat_result: Bool
        let lon_result: Bool

        lat_result = (southwest.latitude...northeast.latitude).contains(coordinate.latitude)
        lon_result = (southwest.longitude...northeast.longitude).contains(coordinate.longitude)

        if !lat_result {
            print("""
                  Latitude FALSE:
                  \(southwest.latitude)...\(northeast.latitude)
                  """)
        }
        if !lon_result {
            print("""
                  Longitude FALSE:
                  \(southwest.longitude)...\(northeast.longitude)
                  """)
        }
        return lat_result && lon_result
    }

    var visualDescription: String {
        """
        [\(northwest.latitude.pad), \(northwest.longitude.pad)]---------[\(northeast.latitude.pad), \(northeast.longitude.pad)]
        |                   +                   |
        [\(southwest.latitude.pad), \(southwest.longitude.pad)]_________[\(southeast.latitude.pad), \(southeast.longitude.pad)]

        """
    }
}

extension CameraBounds {
    var visualDescription: String {
        """
        [\(bounds.northwest.latitude.pad), \(bounds.northwest.longitude.pad)]---------[\(bounds.northeast.latitude.pad), \(bounds.northeast.longitude.pad)]
        |                   +                   |
        [\(bounds.southwest.latitude.pad), \(bounds.southwest.longitude.pad)]_________[\(bounds.southeast.latitude.pad), \(bounds.southeast.longitude.pad)]

        """
    }
}

extension CLLocationDegrees {
    var pad: String {
        String(describing: self).padding(toLength: 6, withPad: " ", startingAt: 0)
    }
}

/// At present (10.0.0-beta.20) the point property of ScreenCoordinate is internal
extension ScreenCoordinate {
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

extension CLLocationCoordinate2D {
    static var squamish: CLLocationCoordinate2D {
        .init(latitude: 49.7817, longitude: -123.162003)
    }
}
