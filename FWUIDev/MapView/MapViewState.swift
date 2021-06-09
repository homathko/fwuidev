//
// Created by Eric Lightfoot on 2021-05-31.
//
import SwiftUI
import CoreLocation
import MapboxMaps

class MapViewState: ObservableObject, LocationConsumer {
    func locationUpdate (newLocation: Location) {
        userSprite = FWMapSprite(model: UserModel(coordinate: newLocation.coordinate), spriteType: .user)
    }

    @Published var userSprite: FWMapSpriteContract?
    @Published var includeUserSprite: Bool = true

    private var userPanConstraint: MapViewConstraintGroup? {
        if let sprite = userSprite, includeUserSprite {
            return .init(.pan([sprite], true))
        } else { return nil }
    }

    /// All annotations that are in .showing prop that are
    /// supposed to be kept in frame at one time
    var focusing: [FWMapSpriteContract] {
        constraints.pan?.annotations() ?? []
    }
    /// Is not nil, the user has selected one annotation among
    /// what is available in .showing by tapping it
    var selectedByTap: FWMapSpriteContract?

    /// Any applied constraints to the current map view
    /// and whether they are overridable
    /// When this property is set the map should update
    @Published private var constraintsQueue: [MapViewConstraintGroup] = []

    /// The current group of constraints
    public var constraints: MapViewConstraintGroup {
        var maybeUser: [MapViewConstraintGroup] = []
        if let constraint = userPanConstraint { maybeUser = [constraint] }
        return (maybeUser + constraintsQueue)
                .reduced()
    }
    /// Remove all constraints
    func reset () {
        constraintsQueue = []
    }
    /// Add new constraints to the FIFO queue
    func push (constraints: [MapViewConstraint]) {
        let group = MapViewConstraintGroup(constraints)
        constraintsQueue.append(group)
    }
    func push (constraint: MapViewConstraint) {
        let group = MapViewConstraintGroup(constraint)
        constraintsQueue.append(group)
    }
    /// Pop the last constraint group off
    func pop (constraints: MapViewConstraintGroup) {
        _ = constraintsQueue.popLast()
    }

    /// Try to solve endless view update cycle
    var shouldUpdateView = false
    var easeSpeed: TimeInterval = 0.2
}

enum MapViewTrackingMode {
    case roaming
    case tracking([FWMapSpriteContract])
}

enum MapViewConstraint {
    case pan([FWMapSpriteContract], Bool)
    case zoom(Double, Bool)
    case heading(Double, Bool)
    case pitch(Double, Bool)

    func annotations () -> [FWMapSpriteContract] {
        switch self {
            case .pan(let annotations, _): return annotations
            default: return []
        }
    }

    func zoomValue () -> CGFloat? {
        switch self {
            case .zoom(let zoom, _): return CGFloat(zoom)
            default: return nil
        }
    }

    func headingValue () -> CGFloat? {
        switch self {
            case .heading(let heading, _): return CGFloat(heading)
            default: return nil
        }
    }

    func pitchValue () -> Double? {
        switch self {
            case .pitch(let pitch, _): return pitch
            default: return nil
        }
    }
}

struct MapViewConstraintGroup {
    var pan: MapViewConstraint?
    var zoom: MapViewConstraint?
    var heading: MapViewConstraint?
    var pitch: MapViewConstraint?

    init () { self.init([]) }

    init (_ constraints: [MapViewConstraint]) {
        constraints.forEach {
            switch $0 {
                case .pan: pan = $0
                case .zoom: zoom = $0
                case .heading: heading = $0
                case .pitch: pitch = $0
            }
        }
    }
    init (_ constraint: MapViewConstraint) {
        self.init([constraint])
    }

    var shownAnnotations: [FWMapSpriteContract] {
        pan?.annotations() ?? []
    }
}

extension Array where Element == MapViewConstraintGroup {
    func reduced () -> MapViewConstraintGroup {
        reduce(MapViewConstraintGroup()) { result, next in
            var reduced = MapViewConstraintGroup()
            if case .pan(let nextAnnotations, let canOverride) = next.pan,
                case .pan(let resultAnnotations, _) = result.pan {
                    reduced.pan = .pan(nextAnnotations + resultAnnotations, canOverride)
            } else {
                reduced.pan = next.pan ?? result.pan
            }
            reduced.zoom = next.zoom ?? result.zoom
            reduced.heading = next.heading ?? result.heading
            reduced.pitch = next.pitch ?? result.pitch
            return reduced
        }
    }
}