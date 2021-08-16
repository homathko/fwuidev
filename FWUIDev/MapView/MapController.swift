//
// Created by Eric Lightfoot on 2021-05-31.
//
import SwiftUI
import CoreLocation
import MapboxMaps
enum MapViewTransitionState: String {
    case idle, gesturing, animating
}
enum MapViewState: Equatable {
    /// Starting state with (or without) user location
    /// Gesturing enabled (free/roaming)
    case base
    /// Constrained to focus on group of sprites
    case constrained([MapViewConstraintGroup])

    static func == (lhs: MapViewState, rhs: MapViewState) -> Bool {
        switch (lhs, rhs) {
            case (.constrained(let lha), .constrained(let rha)):
                return lha == rha
            case (.base, .base):
                return true
            default: return false
        }
    }

    static func ~= (lhs: MapViewState, rhs: MapViewState) -> Bool {
        switch (lhs, rhs) {
            case (.constrained(_), .constrained(_)):
                return true
            case (.base, .base):
                return true
            default: return false
        }
    }

    func constraints () -> MapViewConstraintGroup {
        switch self {
            case .constrained(let constraints):
                return constraints.reduced()
            default: return MapViewConstraintGroup()
        }
    }

    func lastConstraintGroup () -> MapViewConstraintGroup? {
        switch self {
            case .constrained(let constraints):
                return constraints.last
            default: return nil
        }
    }

    func focusing () -> [String] {
        constraints().pan?.annotations().map { $0.id } ?? []
    }
}

struct MapCameraState {
    var center: CLLocationCoordinate2D
    var heading: Double
    var zoom: CGFloat
    var pitch: CGFloat
}

class MapController: ObservableObject {
    /// Map view state
    @Published var state: MapViewState = .base

    @Published var camera = MapCameraState(center: .squamish, heading: 0, zoom: 0, pitch: 0)

    @Published var transState = MapViewTransitionState.animating

    /// All annotations that are in .showing prop that are
    /// supposed to be kept in frame at one time
    var focusing: [String] {
        constraints.pan?.annotations() .map { $0.id } ?? []
    }
    /// Is not nil, the user has selected one annotation among
    /// what is available in .showing by tapping it
    @Published var selectedByTap: FWMapSprite?

    /// Any applied constraints to the current map view
    /// and whether they are overridable
    /// When this property is set the map should update
    internal var constraintsQueue: [MapViewConstraintGroup] = []

    /// The current group of constraints
    public var constraints: MapViewConstraintGroup {
        constraintsQueue.reduced()
    }
    /// Remove all constraints
    func reset () {
        constraintsQueue = []
//        state = .base
    }
    /// Add new constraints to the FILO queue
    func push (constraints: [MapViewConstraint]) {
        let group = MapViewConstraintGroup(constraints)
        constraintsQueue.append(group)
        state = .constrained(constraintsQueue)
    }
    func push (constraint: MapViewConstraint) {
        let group = MapViewConstraintGroup(constraint)
        constraintsQueue.append(group)
        state = .constrained(constraintsQueue)
    }
    func push (group: MapViewConstraintGroup) {
        if !constraintsQueue.contains(group) {
            constraintsQueue.append(group)
            state = .constrained(constraintsQueue)
        }
    }
    func pop () {
        constraintsQueue.removeLast()
        if constraintsQueue.count == 0 {
            state = .base
        } else {
            state = .constrained(constraintsQueue)
        }
    }
    /// Pop the last constraint group off
    func popAfter (index: Int) {
        let last = constraintsQueue.count - (index + 1)
        constraintsQueue.removeLast(last)
        if constraintsQueue.count == 0 {
            state = .base
        } else {
            state = .constrained(constraintsQueue)
        }
    }
}

enum MapViewConstraint: Equatable {
    case pan([FWMapSprite], Bool)
    case zoom(Double, Bool)
    case heading(Double, Bool)
    case pitch(Double, Bool)

    func annotations () -> [FWMapSprite] {
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

struct MapViewConstraintGroup: Equatable {
    static func == (lhs: MapViewConstraintGroup, rhs: MapViewConstraintGroup) -> Bool {
        lhs.pan == rhs.pan &&
                lhs.zoom == rhs.zoom &&
                lhs.heading == rhs.heading &&
                lhs.pitch == rhs.pitch &&
                lhs.shownAnnotations == rhs.shownAnnotations
    }

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

    var shownAnnotations: [FWMapSprite] {
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