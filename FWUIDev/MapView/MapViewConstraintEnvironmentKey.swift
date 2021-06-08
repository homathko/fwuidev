//
// Created by Eric Lightfoot on 2021-06-08.
//

import SwiftUI

struct MapViewConstraintsEnvironmentKey: EnvironmentKey {
    static var defaultValue: MapViewConstraintGroup = .init()
}

extension EnvironmentValues {
    var constraints: MapViewConstraintGroup {
        get { self[MapViewConstraintsEnvironmentKey.self] }
        set { self[MapViewConstraintsEnvironmentKey.self] = newValue }
    }
}
