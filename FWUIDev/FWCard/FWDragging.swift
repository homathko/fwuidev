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

//                    let rect = CGRect(
//                            x: 0,
//                            y: 0,
//                            width: UIScreen.main.bounds.width,
//                            height: max(
//                                    self.cardCenter.y - _cardHeight / 2 + self.dragState.translation.height,
//                                    CardState.full.height(detents)
//                            )
//                    )
//                    onFrameChange(rect, true)
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

        if cardTop >= detentHeight {
            positionAbove = 0.0
            positionBelow = detentHeight
        } else {
            positionAbove = detentHeight
            positionBelow = 700
        }

        if (cardTop - positionAbove) > (positionBelow - cardTop) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }

        if verticalDirection > 0 {

            if Int(positionBelow) == Int(detentHeight) { cardState = .partial } else
            if Int(positionBelow) == 700 { cardState = .collapsed }

        } else if verticalDirection < 0 {

            if Int(positionAbove) == 0 { cardState = .full } else
            if Int(positionAbove) == Int(detentHeight) { cardState = .partial }

        } else {

            if Int(closestPosition) == 0 { cardState = .full } else
            if Int(closestPosition) == Int(detentHeight) { cardState = .partial } else
            if Int(closestPosition) == 700 { cardState = .collapsed }

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
