//
// Created by Eric Lightfoot on 2021-05-12.
//

import SwiftUI

extension DraggableSlideOverCard {
    struct Mod<GestureType: Gesture>: ViewModifier {
        var state: CardState
        var dragState: DragState
        var dragGesture: GestureType
        var cardCenter: CGPoint
        var detents: CardDetents
        var onFrameChange: (CGRect, Bool) -> () = { _, _ in }

        func body (content: Content) -> some View {
            content
                    .frame(height: _cardHeight)
                    .animation(
                            dragState.isDragging ? nil : .interpolatingSpring(
                                    stiffness: 300.0,
                                    damping: 30.0,
                                    initialVelocity: 10.0
                            )
                    )
                    .gesture(dragGesture)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
                    .onAppear {
                        // No drag events yet, send initial value

                        let rect = CGRect(
                                x: 0,
                                y: 0,
                                width: UIScreen.main.bounds.width,
                                height: max(
                                        cardCenter.y - _cardHeight / 2,
                                        CardState.full.height(detents)
                                ))

                        onFrameChange(rect, false)
                    }
        }

        mutating func go () {
            cardCenter = detents.cardCenter(state: state)
        }
    }
}
