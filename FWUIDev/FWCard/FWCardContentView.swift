//
// Created by Eric Lightfoot on 2021-05-13.
//

import SwiftUI

struct FWCardContentView: View {
    @Binding var cardState: FWCardState
    
    var body: some View {
        TabView {
            ZStack {
                Color.gray.opacity(0.4).edgesIgnoringSafeArea(.all)
                GeometryReader { proxy in
                    FWCardView(cardState: $cardState, containerProxy: proxy) {
                        NavigationView {
                            ZStack {
                                Color.purple
                                Text("X").foregroundColor(.white)
                            }
                        }
                    }
                }
            }
                    .tabItem {
                        Image(systemName: "hand.draw.fill")
                        Text("Finger Slap")
                    }
        }
    }
}



struct FWCardContentSubView<Content: View>: View {
    var content: () -> Content

    var body: some View {
        content()
    }
}
