//
// Created by Eric Lightfoot on 2021-06-02.
//

import MapboxMaps
import CoreGraphics
import CoreLocation

protocol FWMapScreenDrawable {
    var id: String { get }

    /// Conforming objects may need to wait to have this
    /// property set
    var point: CGPoint? { get set }

    /// Which SwiftUI View will be used to draw this sprite
    var spriteType: FWMapSpriteType { get }
}

protocol Locatable {
    var location: CLLocation { get }
}