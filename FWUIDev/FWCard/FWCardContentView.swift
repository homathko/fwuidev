//
// Created by Eric Lightfoot on 2021-05-13.
//

import SwiftUI

struct FWCardContentView: View {
    @State var cardState: FWCardState = .collapsed
    @State private var selectedTab: Int = 0

    var body: some View {
        /// Observe taps on tab bar items that change
        /// FWCardView state
        let selection = Binding<Int>(
                get: { selectedTab },
                set: {
                    selectedTab = $0
                    if cardState != .full { cardState = .full } else { cardState = .collapsed }
                })

        /// Begin TabView
        TabView(selection: selection) {
            ZStack {
                Color.gray.opacity(0.4).edgesIgnoringSafeArea(.all)
                FWCardView(cardState: cardState) {
                    ZStack {
                        Color.purple
                        Text("X").foregroundColor(.white)
                    }
                }
            }
                    .tabItem {
                        Image(systemName: "hand.draw.fill")
                        Text("Finger Slap")
                    }.tag(0)
        }
    }
}