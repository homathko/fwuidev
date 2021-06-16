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
    @StateObject var state: MapViewState = .init()
    @State var insets: UIEdgeInsets = .zero
    @State private var cardState: FWCardState = .partial
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
                FWMapView(state: state, insets: $insets, annotations: assets)
                FWCardView(cardState: $cardState, detentHeight: $detentHeight, headerHeight: $headerHeight) {

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

                } onFrameChange: { frame in
                    insets = .init(
                            top: frame.origin.y + 50,
                            left: frame.origin.x + 50,
                            bottom: UIScreen.main.bounds.height - frame.height,
                            right: UIScreen.main.bounds.width - frame.width + 50
                    )
                }
                SafeAreaInsetsView()
            }
                    .environmentObject(state)
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
                    .mapConstraint(.pan([assets[0], assets[1], assets[2]], false), merge: false)
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
                    .mapConstraint(.pan([assets[1]], false), merge: false)
        }
    }
}

struct RedView: View {
    var body: some View {
        NavigationLink(destination:
            Color.black
                .mapConstraints([
//                    .pan([assets[2]], false),
                    .zoom(10, false)
                ] , merge: true)
        ) {
            ZStack {
                Color.red.border(Color.black)
                Text("Pin 3")
            }
                    .mapConstraint(.pan([assets[2]], true), merge: false)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
