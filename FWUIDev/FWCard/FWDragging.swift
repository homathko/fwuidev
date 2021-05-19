//
// Created by Eric Lightfoot on 2021-05-18.
//

import CoreGraphics
import SwiftUI

extension FWCardView {
    var dragGesture: some Gesture {

        DragGesture()
                .updating($dragState) { drag, state, transaction in
                    state = .dragging(translation: drag.translation)

                    /// Call onFrameChange where proxy is available
                }.onEnded { value in
                    onDragEnded(drag: value)
                }
    }

    func onDragEnded (drag: DragGesture.Value) {
        let verticalDirection = max(0, drag.predictedEndLocation.y) - max(0, drag.location.y)
        cardTop = cardTop + drag.translation.height

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
            } else {
                print("No condition met")
            }

        } else if verticalDirection < 0 {

            if Int(positionAbove) == fullPosition {
                newState = .full
            } else if Int(positionAbove) == Int(detentPosition) {
                newState = .partial
            } else {
                print("No condition met")
            }

        } else {

            if Int(closestPosition) == fullPosition {
                newState = .full
            } else if Int(closestPosition) == Int(detentPosition) {
                newState = .partial
            } else if Int(closestPosition) == collapsedPosition {
                newState = .collapsed
            } else {
                print("No condition met")
            }
        }

        if let state = newState {
            cardState = state
        }
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
