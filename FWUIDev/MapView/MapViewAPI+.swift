//
// Created by Eric Lightfoot on 2021-06-08.
//

import SwiftUI

extension View {
    func mapConstraint (_ constraint: MapViewConstraint?, merge: Bool = true) -> some View {
        self.modifier(MapViewConstraintModifier(constraint: constraint, merge: merge))
    }
}

struct MapViewConstraintModifier: ViewModifier {
    @EnvironmentObject var state: MapViewState
    var constraint: MapViewConstraint?
    var merge: Bool

    init (constraint: MapViewConstraint?, merge: Bool = true) {
        self.constraint = constraint
        self.merge = merge
    }

    init () {
        self.init(constraint: nil, merge: false)
    }

    func body(content: Content) -> some View {
        content
                .onAppear {
            if let constraint = constraint {
                if !merge { state.reset() }
                state.push(constraint: constraint)
            } else {
                if !merge { state.reset() }
            }
        }
    }
}