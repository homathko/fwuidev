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

                            YellowView()
                                    .navigationBarTitle("Fucking SwiftUI", displayMode: .inline)
                                    .navigationBarItems(
                                            leading: Button("Collapse") {
                                                cardState = .collapsed
                                            },
                                            trailing: HStack {
                                                Button("Partial") {
                                                    cardState = .partial
                                                }
                                                Button("Full") {
                                                    cardState = .full
                                                }
                                            }
                                    )

                        }

                        SafeAreaInsetsView()
                    }
            }
                    .environmentObject(map)
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
                Text("Pin 1")
                VStack {
                    Color.clear.border(Color.green)
                            .frame(height: 200)
                    Spacer()
                }
            }
                    /// Reset map view state
                    .mapConstraints([
                        .pan([assets[0]], true)
//                        .zoom(9, true)
                    ], merge: false)
        }
    }
}

struct GreenView: View {
    var body: some View {
        NavigationLink(destination: RedView()) {
            ZStack {
                Color.green
                Text("Pin 2")
                VStack {
                    Color.clear.border(Color.black)
                            .frame(height: 100)
                    Spacer()
                }
            }
                    /// Merge in another sprite
                    .mapConstraint(.pan([assets[1]], false), merge: false)
        }
    }
}

struct RedView: View {
    var body: some View {
        ZStack {
            Color.red.border(Color.black)
            Text("Pin 3")
        }
                .mapConstraint(.pan([assets[2]], true), merge: false)
    }
}

struct MyOtherCircle: View {
    @Binding var offset: CGFloat

    var body: some View {
        Circle()
                .fill(Color.blue)
                .frame(width: 50, height: 50)
                .position(x: 100, y: 100 + offset/2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
