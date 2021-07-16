//
// Created by Eric Lightfoot on 2021-06-02.
//

import MapboxMaps
import Turf
import SwiftUI
import CoreGraphics

enum FWMapSpriteType {
    case asset, flightEvent, flightPath, user
}

struct FWMapSprite: Annotation, Locatable, FWMapScreenDrawable, Equatable {
    /// The feature that is backing this annotation.
    var feature: Turf.Feature {
        Turf.Feature(geometry: .point(Point(location.coordinate)))
    }

    var title: String? = nil

    var isSelected: Bool = false

    var userInfo: [String: Any]?

    var id: String

    var location: CLLocation
    var point: CGPoint? = nil
    var spriteType: FWMapSpriteType
    var course: Int? = nil
    var speed: Double? = nil

    init <V: Locatable & Identifiable>(
            model: V,
            spriteType: FWMapSpriteType,
            name: String? = nil,
            userInfo: [String: Any]? = nil
    ) where V.ID == String {
        id = model.id
        location = model.location
        self.spriteType = spriteType
        title = name
        self.userInfo = userInfo
        course = Int(location.course)
        speed = location.speed/0.514444
    }

    static func == (lhs: FWMapSprite, rhs: FWMapSprite) -> Bool {
        lhs.id == rhs.id &&
                lhs.location.timestamp == rhs.location.timestamp &&
                lhs.isSelected == rhs.isSelected
    }

    var isTransmitting: Bool {
        true
    }

    var shouldDisplayAltitude: Bool {
        isTransmitting
    }

    var shouldDisplaySpeed: Bool {
        isTransmitting
    }

    var rotationModifier: RotationModifier {
        .heading(course ?? 0)
    }

    var anchorPoint: UnitPoint = .center


}