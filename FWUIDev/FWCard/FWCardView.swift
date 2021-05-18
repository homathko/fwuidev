//
// Created by Eric Lightfoot on 2021-05-12.
//

import Foundation
import SwiftUI

struct FWCardView<CardContent: View>: View {
    @Binding var cardState: FWCardState
    @Binding var detentHeight: CGFloat
    @Binding var headerHeight: CGFloat
    var bgColor: Color = .pink
    var content: () -> CardContent
    var handleHeight: CGFloat = 20.0

    /// Card should always appear as animating to it's initial position from below
    @State internal var cardTop: CGFloat = UIScreen.main.bounds.height

    @GestureState var dragState = FWDragState.inactive

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) { /// <--- spacing:0 stays!
                if cardState == .full {
                    fullWrappedLayout
                } else {
                    partialWrappedLayout(proxy)
                }
            }
                    .position(position(proxy, forDragTranslation: dragState.translation))
                    .gesture(dragGesture)
                    .animation(.interpolatingSpring(
                            stiffness: 300.0,
                            damping: 30.0,
                            initialVelocity: 10.0
                    ))

                    .onAppear {
                        print("FWCardView: \(proxy.safeAreaInsets)")
                        setCardTopForState(proxy, cardState)
                    }
                    .onChange(of: cardState) { newState in
                        setCardTopForState(proxy, newState)
                    }
        }
    }
    
    var fullWrappedLayout: some View {
        VStack(spacing: 0) {
            DragHandle()
                .frame(width: 150, height: handleHeight)
                    /// Make hit detectable over clear area surrounding handle
                    .contentShape(Rectangle())
            content()
                .background(bgColor)
            
        }
                .background(bgColor.edgesIgnoringSafeArea(.all))
    }
    
    func partialWrappedLayout (_ proxy: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            DragHandle()
                .frame(width: 150, height: handleHeight)
                    /// Make hit detectable over clear area surrounding handle
                    .contentShape(Rectangle())
            content()
                .background(bgColor)
                .cornerRadius(10.0, corners: [.topLeft, .topRight])
                .padding(.leading, 4).padding(.trailing, 4)
//                .edgesIgnoringSafeArea(.bottom)
        }
    }

    internal func position (_ proxy: GeometryProxy) -> CGPoint {
        CGPoint(x: proxy.size.width / 2, y: cardTop + proxy.size.height / 2)
    }

    internal func position (_ proxy: GeometryProxy, forDragTranslation translation: CGSize) -> CGPoint {
        CGPoint(x: proxy.size.width / 2, y: cardTop + proxy.size.height / 2 + translation.height)
    }

    private func setCardTopForState (_ proxy: GeometryProxy, _ state: FWCardState) {
        switch state {
            case .collapsed:
                setCardTop(proxy.size.height - handleHeight)
            case .partial:
                print("Detent height: \(detentHeight), Header height: \(headerHeight)")
                setCardTop(proxy.frame(in: .local).origin.y + proxy.size.height - handleHeight - detentHeight - headerHeight)
            case .full:
                setCardTop(proxy.frame(in: .local).origin.y)
        }
    }

    internal func setCardTop (_ y: CGFloat) {
        withAnimation(.spring(response: 0.4)) {
            cardTop = y
        }
    }
}

struct TopSafeArea_Preview2: PreviewProvider {

    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3)
            FWCardView(cardState: .constant(.partial),
                    detentHeight: .constant(200),
                    headerHeight: .constant(0))
            {
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
}
