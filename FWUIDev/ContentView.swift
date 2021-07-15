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
    var heading: Int = 0

    var spriteType: FWMapSpriteType = .asset
    var point: CGPoint?

    init (coordinate: CLLocationCoordinate2D) {
        location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    var shouldDisplayAltitude: Bool { true }
    var shouldDisplaySpeed: Bool { true }
    var rotationModifier: RotationModifier { .heading(heading) }
    var anchorPoint: UnitPoint { .center }
}

/// Seed data (will come from "AnnotationPublisher" conformer)
var sprites: [FWMapSprite] = [
    FWMapSprite(
            model: AssetModel(coordinate: CLLocationCoordinate2D(latitude: 49.716700, longitude: -123.142448)),
            spriteType: .user,
            name: "User"
    ),
    FWMapSprite(
            model: AssetModel(coordinate: CLLocationCoordinate2D(latitude: 49.316054, longitude: -122.805009)),
            spriteType: .asset,
            name: "Asset 1"
    ),
    FWMapSprite(
            model: AssetModel(coordinate: CLLocationCoordinate2D(latitude: 49.498542, longitude: -123.921399)),
            spriteType: .asset,
            name: "Asset 2"
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
                        FWMapView(map: map, annotations: sprites, cardTop: $cardTop, bottomInset: proxy.safeAreaInsets.bottom)
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
        NavigationLink(destination: GreenView(map: map)) {
            ZStack {
                Color.yellow
                Text("Pin 1")
            }
        }
                .mapConstraint(map: map, .pan([sprites[0]], false), merge: true)
    }
}

struct GreenView: View {
    var map: MapController

    var body: some View {
        NavigationLink(destination: RedView(map: map)) {
            ZStack {
                Color.green
                Text("Pin 2")
                        .mapConstraint(map: map, .pan([sprites[1]], true), merge: true)
            }
        }
    }
}

struct RedView: View {
    var map: MapController
    var body: some View {
        Color.red
                .mapConstraint(map: map, .pan([sprites[2]], true), merge: true)
    }
}
