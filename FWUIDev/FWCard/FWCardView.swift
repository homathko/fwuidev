//
// Created by Eric Lightfoot on 2021-05-12.
//

import Foundation
import SwiftUI

struct FWCardView<CardContent: View>: View {
    var cardState: FWCardState = .full
    var content: () -> CardContent

    var handleHeight: CGFloat = 20.0

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
                    .position(card.center)
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
