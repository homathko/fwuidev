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
    @Binding var cardHeight: CGFloat
    var bgColor: Color = Color(UIColor.systemBackground).opacity(0.65)
    var content: () -> CardContent
    var handleHeight: CGFloat = 20.0

    /// After gesture state changes the card will have to tell
    /// the map to restore it's previous state
    var previousMapState: MapViewState?

    /// Card should always first appear in transition from below
    @State internal var cardTop: CGFloat = UIScreen.main.bounds.height

    @GestureState var dragState = FWDragState.inactive

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
                        .modifier(FullConditionalWrappedLayout(cardState: cardState, bgColor: bgColor))

                FWNavigationView(cardState: $cardState, headerHeight: $headerHeight) {
                    VStack(spacing: 0) { /// <--- spacing:0 stays!
                        if cardState == .full {
                            fullWrappedLayout
                        } else {
                            partialWrappedLayout(proxy)
                        }
                    }
                            .edgesIgnoringSafeArea(.bottom)
                }
            }
                    .position(position(proxy, forDragTranslation: dragState.translation))
                    .gesture(
                        /// Unable to factor out due to dependency on proxy
                            DragGesture()
                                    .updating($dragState) { drag, state, transaction in
                                        state = .dragging(translation: drag.translation)

                                        /// Tell mapview.camera to stop animating
                                        map.interruptState(withState: .gesturing)

                                        let top = cardTop + drag.translation.height
                                        let frame = proxy.frame(in: .global)
                                        print(frame.height - top)
                                        cardHeight = frame.height - top
                                    }
                                    .onEnded { value in
                                        onDragEnded(drag: value)
                                    }
                    )
                    .onAppear {
                        setCardTopForState(proxy, cardState)
                    }
                    .onChange(of: cardState) { newState in
                        setCardTopForState(proxy, newState)
                    }
        }
    }

    var fullWrappedLayout: some View {
        VStack(spacing: 0) {
            content()
                    .background(bgColor)
        }
    }

    struct FullConditionalWrappedLayout: ViewModifier {
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

    func partialWrappedLayout (_ proxy: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            content()
                    .background(bgColor)
                    .cornerRadius(10.0, corners: [.topLeft, .topRight])
                    .padding(.leading, 4).padding(.trailing, 4)
        }
    }

    internal func position (_ proxy: GeometryProxy) -> CGPoint {
        CGPoint(
                x: proxy.size.width / 2,
                y: cardTop + proxy.size.height / 2
        )
    }

    internal func position (_ proxy: GeometryProxy, forDragTranslation translation: CGSize) -> CGPoint {
        CGPoint(
                x: proxy.size.width / 2,
                y: max(cardTop + proxy.size.height / 2 + translation.height, cardTop + proxy.size.height / 2)
        )
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
            let frame = proxy.frame(in: .global)
            cardHeight = frame.height - cardTop
            print("executed once only: \(frame.height - cardTop)")
        }
    }
}

struct TopSafeArea_Preview2: PreviewProvider {

    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3).edgesIgnoringSafeArea(.all)
            FWCardView(cardState: .constant(.full),
                    detentHeight: .constant(200),
                    headerHeight: .constant(44),
                    cardHeight: .constant(100))
            {
                NavigationLink(destination: Color.green) {
                    ZStack {
                        Color.yellow
                        VStack {
                            HStack {
                                Text("Content")
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
            }
                    .edgesIgnoringSafeArea(.bottom)

        }
    }
}
