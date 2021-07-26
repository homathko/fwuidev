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
                        FWMapView(map: map, annotations: $annotations, cardTop: $cardTop, bottomInset: proxy.safeAreaInsets.bottom)
                                .onReceive(coordinator.$annotations) { assets in
                                    annotations = assets
                                }
                        FWCardView(
                                cardState: $cardState,
                                detentHeight: $detentHeight,
                                headerHeight: $headerHeight,
                                cardTop: $cardTop) {

                            YellowView(mapViewState: $map.state)
                                    .navigationBarTitle("Fucking SwiftUI", displayMode: .inline)
                        }
                                .onAppear {
                                    let group = MapViewConstraintGroup([
                                        .pan([coordinator.annotations[0]], true),
                                        .zoom(12.4, true)
                                    ])

                                    map.push(group: group)
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
//    var coordinator: AssetsCoordinator
    @Binding var mapViewState: MapViewState
    var body: some View {
//        NavigationLink(destination: GreenView(coordinator: coordinator, map: map)) {
            ZStack {
                Color.yellow
                VStack {
                    Text("MapController.state: \(mapViewState.description)").padding()
                    Spacer()
                }
            }
//        }
//                .mapConstraints(map: map, [
//                    .pan([coordinator.annotations[0]], true),
//                    .zoom(12.4, true)
//                ], merge: true)
    }
}

//struct GreenView: View {
//    var coordinator: AssetsCoordinator
//    var map: MapController
//
//    var body: some View {
//        NavigationLink(destination: RedView(coordinator: coordinator, map: map)) {
//            ZStack {
//                Color.green
//                Text("Pin 2")
//                        .mapConstraint(map: map, .pan([coordinator.annotations[1]], true), merge: true)
//            }
//        }
//    }
//}
//
//struct RedView: View {
//    var coordinator: AssetsCoordinator
//    var map: MapController
//    var body: some View {
//        Color.red
//                .mapConstraint(map: map, .pan([coordinator.annotations[2]], true), merge: true)
//    }
//}
