//
//  ContentView.swift
//  FWUIDev
//
//  Created by Eric Lightfoot on 2021-05-10.
//

import SwiftUI

struct InsideDraggableCardViewFrame: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce (value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ContentView: View {
    @State var cardState: FWCardState = .full
    @State private var selectedTab: Int = 0
    @State private var detentHeight: CGFloat = 200
    @State private var headerHeight: CGFloat = 0

    var body: some View {
        /// Observe taps on tab bar items that change
        /// FWCardView state
        let selection = Binding<Int>(
                get: { selectedTab },
                set: {
                    selectedTab = $0
                    if cardState != .full {
                        cardState = .partial
                    } else {
                        cardState = .collapsed
                    }
                })

        /// Begin TabView
        TabView(selection: selection) {
            ZStack {
                Color.gray.opacity(0.4).edgesIgnoringSafeArea(.all)
                FWCardView(cardState: $cardState, detentHeight: $detentHeight, headerHeight: $headerHeight, bgColor: .pink) {
//                    NavigationView {
                        GeometryReader { proxy in
                                VStack {
                                    Text("")
                                    Button("Collapse") { cardState = .collapsed }
                                    Button("Partial") { cardState = .partial }
                                    Button("Full") { cardState = .full }
                                    Spacer()
                                }
                                    .onAppear {
                                        headerHeight = proxy.safeAreaInsets.top
                                        print("ContentView: \(proxy.safeAreaInsets)")
                                    }
//                                    .navigationBarTitleDisplayMode(.inline)
//                                    .navigationBarItems(
//                                            leading: Button("Collapse") {
//                                                cardState = .collapsed
//                                            },
//                                            trailing: HStack {
//                                                Button("Partial") {
//                                                    cardState = .partial
//                                                }
//                                                Button("Full") {
//                                                    cardState = .full
//                                                }
//                                            }
//                                    )
//                        }
                    }
                }
//                SafeAreaInsetsView()
            }
                    .tabItem {
                        Image(systemName: "hand.draw.fill")
                        Text("Finger Slap")
                    }.tag(0)
            }
    }
}

struct YellowView: View {
    var body: some View {
        NavigationLink(destination: GreenView()) {
            ZStack {
                Color.yellow
                VStack {
                    Color.clear.border(Color.green)
                            .frame(height: 200)
                    Spacer()
                }
            }
        }
    }
}

struct GreenView: View {
    var body: some View {
        NavigationLink(destination: RedView()) {
            ZStack {
                Color.green
                VStack {
                    Color.clear.border(Color.black)
                            .frame(height: 100)
                    Spacer()
                }
            }
        }
    }
}

struct RedView: View {
    var body: some View {
        NavigationLink(destination: Color.black) {
            Color.red
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
