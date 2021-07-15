//
//  ContentView.swift
//  FWUIDev
//
//  Created by Eric Lightfoot on 2021-05-10.
//

import SwiftUI
import CoreLocation
import UIKit

struct AssetModel: Identifiable, Locatable, FWMapScreenDrawable {
    var id = UUID().uuidString
    var location: CLLocation

    var spriteType: FWMapSpriteType = .asset
    var point: CGPoint?

    init (coordinate: CLLocationCoordinate2D) {
        location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    var shouldDisplayAltitude: Bool { true }
    var shouldDisplaySpeed: Bool { true }
    var rotationModifier: RotationModifier { .alwaysUp }
    var anchorPoint: UnitPoint { .center }
}

/// Seed data (will come from "AnnotationPublisher" conformer)
var assets: [FWMapSprite] = [
    FWMapSprite(
            model: AssetModel(coordinate: CLLocationCoordinate2D(latitude: 49.716700, longitude: -123.142448)),
            spriteType: .asset,
            name: "Pin 1"
    ),
    FWMapSprite(
            model: AssetModel(coordinate: CLLocationCoordinate2D(latitude: 49.316054, longitude: -122.805009)),
            spriteType: .asset,
            name: "Pin 2"
    ),
    FWMapSprite(
            model: AssetModel(coordinate: CLLocationCoordinate2D(latitude: 49.498542, longitude: -123.921399)),
            spriteType: .asset,
            name: "Pin 3"
    )
]

//        +
//        (0...50).map { _ in
//            FWMapSprite(
//                    model: AssetModel(
//                            coordinate: CLLocationCoordinate2D(
//                                    latitude: Double.random(in: 47...51),
//                                    longitude: -Double.random(in: 121...125)
//                            )
//                    ),
//                    spriteType: .asset
//            )
//        }

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
                        FWMapView(map: map, annotations: assets, cardTop: $cardTop, bottomInset: proxy.safeAreaInsets.bottom)
                        FWCardView(
                                cardState: $cardState,
                                detentHeight: $detentHeight,
                                headerHeight: $headerHeight,
                                cardTop: $cardTop) {

                            YellowView(map: map)
                                    .navigationBarTitle("Fucking SwiftUI", displayMode: .inline)
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
    var map: MapController
    var body: some View {
        VStack {
            NavigationLink(destination: GreenView(map: map)) {
                Text("Pin 1")
                        .onAppear {
                            let group = MapViewConstraintGroup(MapViewConstraint.pan([assets[0]], false))
                            print(group.pan?.annotations().first?.title ?? "n/a")
                            map.reset()
                            map.push(group: group)
                        }
            }
            Spacer()
        }
                .background(Color.yellow)
    }
}

struct GreenView: View {
    var map: MapController

    var body: some View {
        VStack {
            NavigationLink(destination: RedView(map: map)) {
                Text("Pin 2")
                        .onAppear {
                            let group = MapViewConstraintGroup(MapViewConstraint.pan([assets[1]], false))
                            print(group.pan?.annotations().first?.title ?? "n/a")
                            map.reset()
                            map.push(group: group)
                        }
            }
            Spacer()
        }
                .background(Color.green)
    }
}

struct RedView: View {
    var map: MapController
    var body: some View {
        Color.red
                .onAppear {
                    let group = MapViewConstraintGroup(MapViewConstraint.pan([assets[2]], false))
                    print(group.pan?.annotations().first?.title ?? "n/a")
                    map.reset()
                    map.push(group: group)
                }
    }
}
