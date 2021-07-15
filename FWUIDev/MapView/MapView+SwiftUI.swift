//
// Created by Eric Lightfoot on 2021-06-08.
//

import SwiftUI

extension View {
    func mapConstraint (_ constraint: MapViewConstraint?, merge: Bool = true) -> some View {
        self.modifier(MapViewConstraintModifier(constraint: constraint, merge: merge))
    }

    func mapConstraints (_ constraints: [MapViewConstraint], merge: Bool = true) -> some View {
        self.modifier(MapViewConstraintModifier(constraints: constraints, merge: merge))
    }
}

struct MapViewConstraintModifier: ViewModifier {
    @EnvironmentObject var map: MapController
    var merge: Bool

    private var group: MapViewConstraintGroup = .init()

    init (constraint: MapViewConstraint?, merge: Bool = true) {
        if let constraint = constraint {
            group = MapViewConstraintGroup(constraint)
        }
        self.merge = merge
    }

    init (constraints: [MapViewConstraint], merge: Bool = true) {
        group = MapViewConstraintGroup(constraints)
        self.merge = merge
    }

    init () {
        self.init(constraint: nil, merge: false)
    }

    func body(content: Content) -> some View {
        content
                .onAppear {
                    print(group.pan?.annotations().first?.title ?? "n/a")
                    map.push(group: group)
//                    map.push(group: group)
//                    if !merge {
//                        map.reset()
//                    }
//                    /// If navigating "back" to this view,
//                    /// the constraints are already here
//                    if let index = map.constraintsQueue.firstIndex(of: group) {
//                        /// And we want them to be the last element
//                        map.popAfter(index: index)
//                    } else {
//                        /// We are navigating forward and want to add
//                        /// this new constraint group
//                        map.push(group: group)
//                    }
                }
    }
}