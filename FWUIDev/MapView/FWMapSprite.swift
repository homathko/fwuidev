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
    var model: AssetModel /// reference type
    /// The feature that is backing this annotation.
    var feature: Turf.Feature {
        Turf.Feature(geometry: .point(Point(location.coordinate)))
    }

    var title: String? { model.title }

    var isSelected: Bool = false

    var userInfo: [String: Any]?

    var id: String { model.id }

    var location: CLLocation { model.location }
    var point: CGPoint? = nil
    var spriteType: FWMapSpriteType { model.spriteType }
    var course: Int { Int(location.course) }
    var speed: Double { location.speed/0.514444 }

    init (model: AssetModel, userInfo: [String: Any]? = nil) {
        self.model = model
        self.userInfo = userInfo
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