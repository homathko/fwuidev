//
// Created by Eric Lightfoot on 2021-05-12.
//

import Foundation
import SwiftUI

struct FWCardView<CardContent: View>: View {
    var cardState: FWCardState = .full
    var content: () -> CardContent

    var handleHeight: CGFloat = 20.0

    @State private var cardTop: CGFloat = 0.0

    var body: some View {
        GeometryReader { proxy in
            let card = FWCard(proxy: proxy, handleHeight: handleHeight, state: cardState)

            VStack(spacing: 0) {
                if cardState == .full {
                    VStack {
                        Color.clear
                    }.frame(width: card.size.width, height: proxy.safeAreaInsets.top)
                }
                VStack {
                    DragHandle().frame(width: 150, height: handleHeight)
                            /// Make hit detectable over clear area surrounding handle
                            .contentShape(Rectangle())
                }.frame(width: card.size.width, height: handleHeight)

                content()
                        .modifier(CardShape(cardState: cardState))

            }
                    .edgesIgnoringSafeArea(.all)
                    .position(x: card.size.width / 2, y: cardTop + card.size.height / 2)

                    .onAppear {
                        switch cardState {
                            case .collapsed:
                                setCardTop(proxy.frame(in: .local).origin.y + proxy.size.height - handleHeight)
                            case .full:
                                setCardTop(proxy.frame(in: .local).origin.y)
                        }
                    }
                    .onChange(of: cardState) { newState in
                        switch newState {
                            case .collapsed:
                                setCardTop(proxy.frame(in: .local).origin.y + proxy.size.height - handleHeight)
                            case .full:
                                setCardTop(proxy.frame(in: .local).origin.y)
                        }
                    }
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
                    FWCardView {
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
