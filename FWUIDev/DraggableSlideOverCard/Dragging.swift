//
// Created by Eric Lightfoot on 2021-05-12.
//

import SwiftUI

extension DraggableSlideOverCard {
    var dragGesture: some Gesture {

        DragGesture()
                .updating($dragState) { drag, state, transaction in
                    let cardTop = cardCenter.y - _cardHeight / 2
                    print("Card top: \((viewableProxy.frame(in: .global).height / 2) - cardTop + drag.translation.height)")

                    state = .dragging(
                            translation: drag.translation.yComponent(
                                    onlyLessThan: CardState.full.height(detents) - cardTop
                            )
                    )
                    let rect = CGRect(
                            x: 0,
                            y: 0,
                            width: UIScreen.main.bounds.width,
                            height: max(
                                    self.cardCenter.y - _cardHeight / 2 + self.dragState.translation.height,
                                    CardState.full.height(detents)
                            )
                    )
                    onFrameChange(rect, true)
                }.onEnded { value in
                    onDragEnded(drag: value)
                }
    }
}
