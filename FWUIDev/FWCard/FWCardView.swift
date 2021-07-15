//
// Created by Eric Lightfoot on 2021-05-12.
//

import Foundation
import SwiftUI

struct FWCardView<CardContent: View>: View {
    /// FWCardView and all child views will
    /// need to take part in changing maps state
    @EnvironmentObject var map: MapController

    @Binding var cardState: FWCardState
    @Binding var detentHeight: CGFloat
    @Binding var headerHeight: CGFloat
    @Binding internal var cardTop: CGFloat
    var bgColor: Color = Color(UIColor.systemBackground).opacity(0.65)
    var content: () -> CardContent
    var handleHeight: CGFloat = 20.0


    /// After gesture state changes the card will have to tell
    /// the map to restore it's previous state
    var previousMapState: MapViewState?

    /// Card should always first appear in transition from below

    @GestureState var dragState = FWDragState.inactive
    @State var lastOffsetY: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {

                HStack {
                    DragHandle()
                            .frame(width: proxy.frame(in: .local).width, height: handleHeight)
                            /// Make hit detectable over clear area surrounding handle
                            .contentShape(Rectangle())
                }
                        /// Drag handle has a background color if card state is full screen
                        .modifier(DragHandleConditionalWrappedLayout(cardState: cardState, bgColor: bgColor))

                FWNavigationView(cardState: $cardState, headerHeight: $headerHeight) {
                    VStack(spacing: 0) { /// <--- spacing:0 stays!

                        content()
                                .background(bgColor)


                    }
                            .edgesIgnoringSafeArea(.bottom)
                }
            }
                    .offset(y: max(0, cardTop))
                    .gesture(
                            DragGesture()
                                    .onChanged { gesture in
                                        cardTop = lastOffsetY + gesture.translation.height
                                    }
                                    .onEnded { drag in
                                        onDragEnded(drag: drag)
                                    }
                    )
                    .onAppear {
                        lastOffsetY = cardTop
                        setCardTopForState(proxy, cardState)
                    }
                    .onChange(of: cardState) { newState in
                        setCardTopForState(proxy, newState)
                    }
        }
    }

    struct DragHandleConditionalWrappedLayout: ViewModifier {
        var cardState: FWCardState
        var bgColor: Color

        func body(content: Content) -> some View {
            if cardState == .full {
                content
                        .background(bgColor.edgesIgnoringSafeArea(.all))
            } else {
                content
            }
        }
    }

    private func setCardTopForState (_ proxy: GeometryProxy, _ state: FWCardState) {
        switch state {
            case .collapsed:
                setCardTop(proxy: proxy, y: proxy.size.height - handleHeight)
            case .partial:
                setCardTop(proxy: proxy, y: proxy.frame(in: .local).origin.y + proxy.size.height - handleHeight - detentHeight - headerHeight)
            case .full:
                setCardTop(proxy: proxy, y: proxy.frame(in: .local).origin.y)
        }
    }

    internal func setCardTop (proxy: GeometryProxy, y: CGFloat) {
        withAnimation(.spring(response: 0.3)) {
            cardTop = y
        }
        lastOffsetY = cardTop
    }
}