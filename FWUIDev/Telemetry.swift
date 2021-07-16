//
// Created by Eric Lightfoot on 2021-07-16.
//

import Combine
import CoreLocation

class TelemetryMocker: ObservableObject {
    @Published var location: CLLocation

    private var timer: Timer?

    init (start: CLLocation) {
        location = start
    }

    public func start (speedInKnots knots: Double, direction: Direction) {
        let interval = direction == .west ? -(1/60 * (knots/3600)) : 1/60 * (knots/3600)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.location = CLLocation(
                    coordinate: CLLocationCoordinate2D(
                            latitude: self.location.coordinate.latitude,
                            longitude: self.location.coordinate.longitude + interval
                    ),
                    altitude: 2000,
                    horizontalAccuracy: .greatestFiniteMagnitude,
                    verticalAccuracy: .greatestFiniteMagnitude,
                    course: direction == .west ? 270 : 90,
                    speed: knots*0.514444,
                    timestamp: Date()
            )

        }
    }
}