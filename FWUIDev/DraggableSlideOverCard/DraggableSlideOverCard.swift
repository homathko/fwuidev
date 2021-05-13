//
// Created by Eric Lightfoot on 2020-10-22.
// Copyright (c) 2020 HomathkoTech. All rights reserved.
//

import SwiftUI

let _dragHandleFrameHeight: CGFloat = 20.0
let _cardHeight: CGFloat = UIScreen.main.bounds.height

struct DraggableSlideOverCard<CardContent: View>: View {
    @State var state: CardState = .collapsed

    @State var cardCenter: CGPoint = .zero /*CGPoint(
            x: UIScreen.main.bounds.width / 2,
            y: _cardHeight
    )*/

    @Binding var detents: CardDetents
    var viewableProxy: GeometryProxy
    var content: () -> CardContent
    var onFrameChange: (CGRect, Bool) -> () = { _, _ in
    }

    @GestureState var dragState = DragState.inactive

    var body: some View {
        print("CardState: \(state) Height: \(detents[state])")
        return VStack {
            DragHandle().frame(width: 150, height: _dragHandleFrameHeight)
                    /// Make hit detectable over clear area surrounding handle
                    .contentShape(Rectangle())
            content()
                    .cornerRadius(10.0, corners: [.topLeft, .topRight])
                    .padding(.leading, 4).padding(.trailing, 4)
        }
                .onPreferenceChange(DraggableSlideOverCardPositionPreferenceKey.self) { info in
                    self.detents[info.state] = info.height
                }
                .position(
                        x: cardCenter.x,
                        y: finalPositionComputation
                )
                .modifier(Mod(state: state, dragState: dragState, dragGesture: dragGesture, cardCenter: cardCenter, detents: detents))
    }

    var finalPositionComputation: CGFloat {
        viewableProxy.frame(in: .global).height
                - state.height(detents)
                + _cardHeight / 2
                + dragState.translation.height
                - 29
    }

    func onDragEnded (drag: DragGesture.Value) {
        let verticalDirection = max(0, drag.predictedEndLocation.y) - max(0, drag.location.y)
        let cardTopEdgeLocation = self.cardCenter.y - _cardHeight / 2 + drag.translation.height
        let positionAbove: CGFloat
        let positionBelow: CGFloat
        let closestPosition: CGFloat

        print("CardTopEdgeLocation: \(cardTopEdgeLocation)")
        if cardTopEdgeLocation >= detents[.partial] {
            positionAbove = detents[.full]
            positionBelow = detents[.partial]
        } else {
            positionAbove = detents[.partial]
            positionBelow = detents[.collapsed]
        }

        if (cardTopEdgeLocation - positionAbove) > (positionBelow - cardTopEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }

        if verticalDirection > 0 {
            self.cardCenter.y = positionBelow + _cardHeight / 2
            state.setState(detents, forHeight: self.cardCenter.y - _cardHeight / 2)
        } else if verticalDirection < 0 {
            self.cardCenter.y = positionAbove + _cardHeight / 2
            state.setState(detents, forHeight: self.cardCenter.y - _cardHeight / 2)
        } else {
            self.cardCenter.y = closestPosition + _cardHeight / 2
            state.setState(detents, forHeight: self.cardCenter.y - _cardHeight / 2)
        }

        let rect = CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: max(cardCenter.y - _cardHeight / 2, CardState.full.height(detents))
        )
        onFrameChange(rect, false)
    }
}