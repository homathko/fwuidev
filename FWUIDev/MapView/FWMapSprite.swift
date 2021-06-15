//
// Created by Eric Lightfoot on 2021-06-02.
//

import MapboxMaps
import Turf
import CoreGraphics

enum FWMapSpriteType {
    case asset, flightEvent, flightPath
    func annotationType () -> AnnotationType {
        switch self {
            case .asset: return .point
            case .flightEvent: return .point
            case .flightPath: return .polyline
        }
    }
}

struct FWMapSprite: Annotation, Locatable, FWMapScreenDrawable, Equatable {
    static func == (lhs: FWMapSprite, rhs: FWMapSprite) -> Bool {
        lhs.id == rhs.id
    }

    /// The feature that is backing this annotation.
    var feature: Turf.Feature {
        Turf.Feature(Point(location.coordinate))
    }

    var title: String? = nil

    var type: AnnotationType { spriteType.annotationType() }

    var isSelected: Bool = false
    var userInfo: [String: Any]? = nil

    var id: String
    var location: CLLocation
    var point: CGPoint? = nil
    var spriteType: FWMapSpriteType
    var course: Int? = nil
    var speed: Double? = nil

    init <V: Identifiable & Locatable>(model: V, spriteType: FWMapSpriteType, name: String? = nil) where V.ID == String {
        id = model.id
        location = model.location
        self.spriteType = spriteType
        title = name
    }
}