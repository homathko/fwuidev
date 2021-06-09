//
// Created by Eric Lightfoot on 2021-06-08.
//

import Foundation
import CoreGraphics
import CoreLocation

struct AssetModel: Identifiable, Locatable, FWMapScreenDrawable {
    var id = UUID().uuidString
    var location: CLLocation

    var spriteType: FWMapSpriteType = .asset
    var point: CGPoint?

    init (coordinate: CLLocationCoordinate2D) {
        location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

struct UserModel: Identifiable, Locatable, FWMapScreenDrawable {
    var id: String { "__user__sprite" }

    var location: CLLocation

    var point: CGPoint?

    var spriteType: FWMapSpriteType = .user

    init (coordinate: CLLocationCoordinate2D) {
        location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}