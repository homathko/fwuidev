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

    init <V: Locatable>(
            model: V,
            spriteType: FWMapSpriteType,
            name: String? = nil,
            userInfo: [String: Any]? = nil
    ) {
        id = UUID().uuidString
        location = model.location
        self.spriteType = spriteType
        title = name
        self.userInfo = userInfo
        if let hasCourseSpeed = model as? HasCourseSpeed {
            course = hasCourseSpeed.course
            speed = hasCourseSpeed.speed
        }
    }

    static func == (lhs: FWMapSprite, rhs: FWMapSprite) -> Bool {
        lhs.id == rhs.id &&
                lhs.location.timestamp == rhs.location.timestamp
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
        .heading(userInfo?["course"] as? Int ?? 0)
    }

    var anchorPoint: UnitPoint = .center


}