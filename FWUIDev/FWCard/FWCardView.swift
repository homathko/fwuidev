//
// Created by Eric Lightfoot on 2021-05-12.
//

import Foundation
import SwiftUI

struct FWCardView<CardContent: View>: View {
    @Binding var cardState: FWCardState
    var content: () -> CardContent

    var handleHeight: CGFloat = 20.0

    /// Card should always appear as animating to it's initial position from below
    @State private var cardTop: CGFloat = UIScreen.main.bounds.height

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {

                /// Safe area insets top edge spacer for .full state
                if cardState == .full {
                    VStack {
                        Color.clear
                    }.frame(width: proxy.size.width, height: proxy.safeAreaInsets.top)
                }
                /// Drag control handle
                VStack {
                    DragHandle().frame(width: 150, height: handleHeight)
                            /// Make hit detectable over clear area surrounding handle
                            .contentShape(Rectangle())
                }.frame(width: proxy.size.width, height: handleHeight)

                /// Wrapped content
                content()
                        .modifier(CardShape(cardState: cardState))

            }
                    .edgesIgnoringSafeArea(.all)
                    .position(position(proxy))

                    .onAppear {
                        setCardTopForState(proxy, cardState)
                    }
                    .onChange(of: cardState) { newState in
                        setCardTopForState(proxy, newState)
                    }
        }
    }

    private func position (_ proxy: GeometryProxy) -> CGPoint {
        CGPoint(x: proxy.size.width / 2, y: cardTop + proxy.size.height / 2)
    }

    private func position (_ proxy: GeometryProxy, forDragTranslation translation: CGSize) -> CGPoint {
        CGPoint(x: position(proxy).x, y: position(proxy).y + translation.height)
    }

    private func setCardTopForState (_ proxy: GeometryProxy, _ state: FWCardState) {
        switch state {
            case .collapsed:
                setCardTop(proxy.frame(in: .local).origin.y + proxy.size.height - handleHeight)
            case .full:
                setCardTop(proxy.frame(in: .local).origin.y)
        }
    }

    private func setCardTop (_ y: CGFloat) {
        withAnimation(.spring(response: 0.3)) {
            cardTop = y
        }
    }
}

struct FWCardView_Preview: PreviewProvider {
    static var previews: some View {
        TabView {
            ZStack {
                Color.blue.opacity(0.4).edgesIgnoringSafeArea(.all)
                GeometryReader { proxy in
                    FWCardView(cardState: .constant(.full)) {
                        NavigationView {
                            Color.yellow
                                    .navigationBarTitle("Feed")
                                    .navigationBarItems(leading: Button("Collapse", action: {}), trailing: Button("Full", action: {}))
                        }
                    }
                }
            }
                .tabItem {
                    Image(systemName: "hand.draw.fill")
                    Text("Slap")
                }
        }
    }
}