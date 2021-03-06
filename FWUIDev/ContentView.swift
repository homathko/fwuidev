//
//  ContentView.swift
//  FWUIDev
//
//  Created by Eric Lightfoot on 2021-05-10.
//

import SwiftUI
import CoreLocation
import UIKit

struct ContentView: View {
    @StateObject var map: MapController = .init()
    @State private var cardState: FWCardState = .partial
    @State private var cardTransState: FWCardTransitionState = .animating
    @State private var selectedTab: Int = 0
    @State private var detentHeight: CGFloat = 200
    @State private var headerHeight: CGFloat = 0
    @State var cardTop: CGFloat = UIScreen.main.bounds.height

    @StateObject var coordinator = AssetsCoordinator()
    @State var annotations: [FWMapSprite] = []

    var body: some View {
        /// Observe taps on tab bar items that change
        /// FWCardView state
        let selection = Binding<Int>(
                get: { selectedTab },
                set: {
                    if cardState != .full {
                        cardState = .partial
                    } else {
                        cardState = .collapsed
                    }

                    /// Make this the last step
                    selectedTab = $0
                })

            /// Begin TabView
            TabView(selection: selection) {
                GeometryReader { proxy in
                    ZStack {
                        FWMapView(map: map, annotations: $annotations, cardTop: $cardTop, cardTransState: $cardTransState, bottomInset: proxy.safeAreaInsets.bottom)
                                .onReceive(coordinator.$annotations) { assets in
                                    annotations = assets
                                }
                        FWCardView(
                                cardState: $cardState,
                                transState: $cardTransState,
                                detentHeight: $detentHeight,
                                headerHeight: $headerHeight,
                                cardTop: $cardTop) {

                            YellowView(coordinator: coordinator, cardTransState: $cardTransState)
                                    .navigationBarTitle("Fucking SwiftUI", displayMode: .inline)
                        }
                    }
                    .environmentObject(map)
            }
                    .tabItem {
                        Image(systemName: "hand.draw.fill")
                        Text("Finger Slap")
                    }
                    .tag(0)
        }
    }
}

struct YellowView: View {
    @EnvironmentObject var map: MapController
    var coordinator: AssetsCoordinator
    @Binding var cardTransState: FWCardTransitionState
    var body: some View {
        NavigationLink(destination: GreenView(coordinator: coordinator, map: map)) {
            ZStack {
                Color.yellow
                VStack {
                    Text("Card Transition State: \(cardTransState.rawValue)").padding()
                    Spacer()
                }
            }
                    .mapConstraints(map: map, [.pan([coordinator.annotations[2]], true), .zoom(11, true)], merge: false)
        }
    }
}

struct GreenView: View {
    var coordinator: AssetsCoordinator
    var map: MapController

    var body: some View {
        NavigationLink(destination: RedView(coordinator: coordinator, map: map)) {
            ZStack {
                Color.green
                Text("Pin 2")
            }
                    .mapConstraint(map: map, .pan([coordinator.annotations[0]], true), merge: false)
        }
    }
}

struct RedView: View {
    var coordinator: AssetsCoordinator
    var map: MapController
    var body: some View {
        Color.red
                .mapConstraint(map: map, .pan([coordinator.annotations[1]], true), merge: true)
    }
}
