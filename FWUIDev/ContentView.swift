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

struct DetentHeightChange: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce (value: inout CGFloat, nextValue: () -> CGFloat) {
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
                MapboxMap().edgesIgnoringSafeArea(.all)
//                Color.gray.opacity(0.4).edgesIgnoringSafeArea(.all)
                FWCardView(cardState: $cardState, detentHeight: $detentHeight, headerHeight: $headerHeight, bgColor: .white) {
                    FWNavigationView(cardState: $cardState, headerHeight: $headerHeight) {
                        YellowView(detentHeight: $detentHeight)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(
                                    leading: Button("Collapse") { cardState = .collapsed },
                                    trailing: HStack {
                                        Button("Partial") { cardState = .partial }
                                        Button("Full") { cardState = .full }
                                    }
                            )
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
    @State var detent: CGFloat = 0.0
    @Binding var detentHeight: CGFloat

    var body: some View {
        NavigationLink(destination: GreenView(detentHeight: $detentHeight)) {
            ZStack {
                Color.yellow
                VStack {
                    Color.clear.border(Color.green)
                            .frame(height: 200)
                            .preference(key: DetentHeightChange.self, value: 200)
                    Spacer()
                }
            }
        }
                .onPreferenceChange(DetentHeightChange.self) { value in
                    self.detent = value
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                        self.detentHeight = detent
                    }
                }
    }
}

struct GreenView: View {
    @State var detent: CGFloat = 0.0
    @Binding var detentHeight: CGFloat

    var body: some View {
        NavigationLink(destination: RedView(detentHeight: $detentHeight)) {
            ZStack {
                Color.green
                VStack {
                    Color.clear.border(Color.black)
                            .frame(height: 100)
                            .preference(key: DetentHeightChange.self, value: 100)
                    Spacer()
                }
            }
        }
                .onPreferenceChange(DetentHeightChange.self) { value in
                    self.detent = value
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                        self.detentHeight = detent
                    }
                }
    }
}

struct RedView: View {
    @State var detent: CGFloat = 0.0
    @Binding var detentHeight: CGFloat

    var body: some View {
        NavigationLink(destination: Color.black) {
            Color.red.border(Color.black)
                    .frame(height: 300)
                    .preference(key: DetentHeightChange.self, value: 300)
        }
                .onPreferenceChange(DetentHeightChange.self) { value in
                    detent = value
                }
                .onAppear {
                    detentHeight = detent
                }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
