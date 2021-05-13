//
// Created by Eric Lightfoot on 2021-05-12.
//

import Foundation
import SwiftUI

struct FWCardView<CardContent: View>: View {
    private var card: FWCard
    private var container: GeometryProxy

    var content: () -> CardContent
    var cardState: FWCardState = .collapsed

    var handleThickness: CGFloat = 20.0

    init (containerProxy: GeometryProxy, @ViewBuilder content: @escaping () -> CardContent) {
        container = containerProxy
        self.content = content
        card = FWCard(size: container.size, rect: container.frame(in: .global), handleHeight: handleThickness)
        switch cardState {
            case .collapsed:
                card.top = container.frame(in: .local).origin.y + container.size.height - handleThickness
            case .full:
                card.top = container.frame(in: .local).origin.y
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if cardState == .full {
                VStack {
                    Color.clear
                }.frame(width: card.size.width, height: container.safeAreaInsets.top)
            }
            VStack {
                DragHandle().frame(width: 150, height: handleThickness)
                    /// Make hit detectable over clear area surrounding handle
                    .contentShape(Rectangle())
            }.frame(width: card.size.width, height: handleThickness)
            
            content()
                    .modifier(CardShape(cardState: cardState))
                
        }
                .edgesIgnoringSafeArea(.all)
                .position(card.center)
    }

    struct CardShape: ViewModifier {
        var cardState: FWCardState

        func body (content: Content) -> some View {
            Group {
                if cardState != .full {
                    content
                            .cornerRadius(10.0, corners: [.topLeft, .topRight])
                            .padding(.leading, 4).padding(.trailing, 4)
                            .edgesIgnoringSafeArea(.bottom)
                } else {
                    content.edgesIgnoringSafeArea(.all)
                }
            }
        }
    }
}

struct FWCardView_Preview: PreviewProvider {
    static var previews: some View {
        TabView {
            ZStack {
                Color.blue.opacity(0.4).edgesIgnoringSafeArea(.all)
                GeometryReader { proxy in
                    FWCardView(containerProxy: proxy) {
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
