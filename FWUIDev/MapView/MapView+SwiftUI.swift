//
// Created by Eric Lightfoot on 2021-06-08.
//

import SwiftUI

extension View {
    func mapConstraint (map: MapController, _ constraint: MapViewConstraint?, merge: Bool = true) -> some View {
        self.modifier(MapViewConstraintModifier(map: map, constraint: constraint, merge: merge))
    }

    func mapConstraints (map: MapController, _ constraints: [MapViewConstraint], merge: Bool = true) -> some View {
        self.modifier(MapViewConstraintModifier(map: map, constraints: constraints, merge: merge))
    }
}

struct MapViewConstraintModifier: ViewModifier {
    var map: MapController
    var merge: Bool

    private var group: MapViewConstraintGroup = .init()

    init (map: MapController, constraint: MapViewConstraint?, merge: Bool = true) {
        self.map = map
        if let constraint = constraint {
            group = MapViewConstraintGroup(constraint)
        }
        self.merge = merge
    }

    init (map: MapController, constraints: [MapViewConstraint], merge: Bool = true) {
        self.map = map
        group = MapViewConstraintGroup(constraints)
        self.merge = merge
    }

    init (map: MapController) {
        self.init(map: map, constraint: nil, merge: false)
    }

    func body(content: Content) -> some View {
        content
                .onAppear {
                    if !merge {
                        map.reset()
                    }
                    /// If navigating "back" to this view,
                    /// the constraints are already here
                    if let index = map.constraintsQueue.firstIndex(of: group) {
                        /// And we want them to be the last element
                        map.popAfter(index: index)
                    } else {
                        /// We are navigating forward and want to add
                        /// this new constraint group
                        map.push(group: group)
                    }
                }
    }
}