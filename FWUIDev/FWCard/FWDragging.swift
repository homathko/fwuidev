//
// Created by Eric Lightfoot on 2021-05-18.
//

import CoreGraphics
import SwiftUI

extension FWCardView {
    func onDragEnded (drag: DragGesture.Value) {
        let verticalDirection = max(0, drag.predictedEndLocation.y) - max(0, drag.location.y)
        cardTop = max(cardTop + drag.translation.height, 0)

        let positionAbove: CGFloat
        let positionBelow: CGFloat
        let closestPosition: CGFloat

        let fullPosition: Int = 100
        let detentPosition: CGFloat = 350
        let collapsedPosition: Int = 640
        
        var newState: FWCardState? = nil

        if cardTop <= detentPosition {
            positionAbove = CGFloat(fullPosition)
            positionBelow = detentPosition
        } else {
            positionAbove = detentPosition
            positionBelow = CGFloat(collapsedPosition)
        }

        if (cardTop - positionAbove) < (positionBelow - cardTop) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }

        if verticalDirection > 0 {

            if Int(positionBelow) == Int(detentPosition) {
                newState = .partial
            } else if Int(positionBelow) == collapsedPosition {
                newState = .collapsed
            }

        } else if verticalDirection < 0 {

            if Int(positionAbove) == fullPosition {
                newState = .full
            } else if Int(positionAbove) == Int(detentPosition) {
                newState = .partial
            }

        } else {

            if Int(closestPosition) == fullPosition {
                newState = .full
            } else if Int(closestPosition) == Int(detentPosition) {
                newState = .partial
            } else if Int(closestPosition) == collapsedPosition {
                newState = .collapsed
            }
        }

        assert(newState != nil, "FWCard state didn't meet any condition to update")
        cardState = newState!
    }
}

public enum FWDragState {
    case inactive
    case dragging(translation: CGSize)

    var translation: CGSize {
        switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
        }
    }

    var isDragging: Bool {
        switch self {
            case .inactive:
                return false
            case .dragging:
                return true
        }
    }
}
