//
// Created by Eric Lightfoot on 2021-06-15.
//

import Foundation

extension MapViewState: Equatable {
    static func == (lhs: MapViewState, rhs: MapViewState) -> Bool {
        /// focusing == focusing
        lhs.focusing == rhs.focusing &&
        /// selectedByTap == selectedByTap
        lhs.selectedByTap == rhs.selectedByTap &&
        /// constraintQueue == constraintQueue
        lhs.constraintsQueue == rhs.constraintsQueue &&
        /// easeSpeed == easeSpeed
        lhs.easeSpeed == rhs.easeSpeed
    }
}

extension MapViewState: NSCopying {
    func copy (with zone: NSZone? = nil) -> Any {
        let copy = MapViewState()
        copy.selectedByTap = selectedByTap
        copy.constraintsQueue = constraintsQueue
        copy.easeSpeed = easeSpeed

        return copy
    }
}
