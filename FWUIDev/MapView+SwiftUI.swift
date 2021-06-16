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
    @EnvironmentObject var state: MapViewState
    var constraints: [MapViewConstraint]
    var merge: Bool

    init (constraint: MapViewConstraint?, merge: Bool = true) {
        constraints = constraint == nil ? [] : [constraint!]
        self.merge = merge
    }

    init (constraints: [MapViewConstraint], merge: Bool = true) {
        self.constraints = constraints
        self.merge = merge
    }

    init () {
        self.init(constraint: nil, merge: false)
    }

    func body(content: Content) -> some View {
        content
                .onAppear {
                    if let _ = constraints.first {
                        if !merge { state.reset() }
                        state.push(constraints: constraints)
                    } else {
                        if !merge { state.reset() }
                    }
                }
    }
}