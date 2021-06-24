//
// Created by Eric Lightfoot on 2021-06-02.
//

import MapboxMaps
import Turf
import CoreGraphics
import SwiftUI
import CoreLocation

protocol FWMapScreenDrawable {
    var id: String { get }

    /// Conforming objects may need to wait to have this
    /// property set
    var point: CGPoint? { get set }

    /// Which SwiftUI View will be used to draw this sprite
    var spriteType: FWMapSpriteType { get }

    /// Depending on state, certain telemetry should be hidden
    var shouldDisplayAltitude: Bool { get }
    var shouldDisplaySpeed: Bool { get }

    /// User manipulated camera rotation affects
    /// sprites differently
    var rotationModifier: RotationModifier { get }
    var anchorPoint: UnitPoint { get }
}

protocol Locatable {
    var location: CLLocation { get }
    func distance (from location: CLLocation) -> CLLocationDistance
}

extension Locatable {
    func distance (from location: CLLocation) -> CLLocationDistance {
        self.location.distance(from: location)
    }
}

protocol HasCourseSpeed {
    var course: Int { get }
    var speed: Double { get }
}

enum RotationModifier {
    case none
    case alwaysUp
    case heading(Int)
}