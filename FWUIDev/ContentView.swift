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
    @State var insets: UIEdgeInsets = .zero
    @State private var cardState: FWCardState = .partial
    @State private var selectedTab: Int = 0
    @State private var detentHeight: CGFloat = 200
    @State private var headerHeight: CGFloat = 0
    @State var cardTop: CGFloat = UIScreen.main.bounds.height
    @State var mapInsetBottomPadding: CGFloat = UIScreen.main.bounds.height
    @State var cardHeight: CGFloat = UIScreen.main.bounds.height

    @ObservedObject var coordinator = AssetsCoordinator()
    @State var annotations: [FWMapSprite] = []

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
                GeometryReader { proxy in
                    ZStack {
                        FWMapView(map: map, annotations: $annotations, cardTop: $cardTop, bottomInset: proxy.safeAreaInsets.bottom)
                                .onReceive(coordinator.$annotations) { assets in
                                    annotations = assets
                                }
                        FWCardView(
                                cardState: $cardState,
                                detentHeight: $detentHeight,
                                headerHeight: $headerHeight,
                                cardTop: $cardTop) {

                            YellowView(map: map)
                                    .navigationBarTitle("Fucking SwiftUI", displayMode: .inline)
                                    .environmentObject(coordinator)
                        }
                            .environmentObject(map)
                    }
            }
                    .tabItem {
                        Image(systemName: "hand.draw.fill")
                        Text("Finger Slap")
                    }.tag(0)
        }
    }
}

struct YellowView: View {
    @EnvironmentObject var coordinator: AssetsCoordinator
    var map: MapController
    var body: some View {
        NavigationLink(destination: GreenView(map: map)) {
            ZStack {
                Color.yellow
                Text("Pin 1")
            }
        }
                .mapConstraint(map: map, .pan([coordinator.annotations[0]], false), merge: true)
    }
}

struct GreenView: View {
    @EnvironmentObject var coordinator: AssetsCoordinator
    var map: MapController

    var body: some View {
        NavigationLink(destination: RedView(map: map)) {
            ZStack {
                Color.green
                Text("Pin 2")
                        .mapConstraint(map: map, .pan([coordinator.annotations[1]], true), merge: true)
            }
        }
    }
}

struct RedView: View {
    @EnvironmentObject var coordinator: AssetsCoordinator
    var map: MapController
    var body: some View {
        Color.red
                .mapConstraint(map: map, .pan([coordinator.annotations[2]], true), merge: true)
    }
}
