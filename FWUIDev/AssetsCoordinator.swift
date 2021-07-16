//
// Created by Eric Lightfoot on 2021-07-16.
//

import Combine
import SwiftUI
import CoreGraphics
import CoreLocation

class AssetsCoordinator: ObservableObject {

    private var assets: [AssetModel]
    @Published var annotations: [FWMapSprite] = []
    private var cancellables: Set<AnyCancellable> = .init()

    init () {
        assets = [
            AssetModel(
                    coordinate: CLLocationCoordinate2D(latitude: 49.716700, longitude: -123.142448),
                    title: "ASS1",
                    spriteType: .asset
            ),
            AssetModel(
                    coordinate: CLLocationCoordinate2D(latitude: 49.316054, longitude: -122.805009),
                    title: "ASS2",
                    spriteType: .asset
            ),
            AssetModel(
                    coordinate: CLLocationCoordinate2D(latitude: 49.498542, longitude: -123.921399),
                    title: "USR",
                    spriteType: .user
            )
        ]

        assets.forEach { asset in
            asset.$location.sink { loc in
                if let i = self.annotations.firstIndex(where: { $0.id == asset.id } ) {
                    self.annotations.remove(at: i)
                    self.annotations.insert(
                            FWMapSprite(model: asset, spriteType: asset.spriteType, name: asset.title),
                            at: i
                    )
                }
            }.store(in: &cancellables)
        }

        annotations = assets.map {
            FWMapSprite(
                    model: $0,
                    spriteType: $0.spriteType,
                    name: $0.title
            )
        }

        /// Make ASS1 move
        assets[0].start(speed: 100, direction: .west)
        assets[1].start(speed: 100, direction: .east)
    }
}

enum Direction {
    case east, west
}

class AssetModel: Identifiable, Locatable, FWMapScreenDrawable, ObservableObject {
    var id = UUID().uuidString
    @Published var location: CLLocation

    var heading: Int {
        Int(location.course)
    }

    var title: String

    var spriteType: FWMapSpriteType = .asset
    var point: CGPoint?

    var cancellable: AnyCancellable?

    init (coordinate: CLLocationCoordinate2D, title: String, spriteType: FWMapSpriteType) {
        location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.title = title
        self.spriteType = spriteType
        telemetryMocker = TelemetryMocker(start: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }

    func start (speed: Double, direction: Direction) {
        cancellable = telemetryMocker.$location.receive(on: DispatchQueue.main).sink { loc in
            self.location = loc
        }

        telemetryMocker.start(speedInKnots: speed, direction: direction)
    }

    var shouldDisplayAltitude: Bool { true }
    var shouldDisplaySpeed: Bool { true }
    var rotationModifier: RotationModifier { .heading(heading) }
    var anchorPoint: UnitPoint { .center }

    var telemetryMocker: TelemetryMocker
}