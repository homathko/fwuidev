//
// Created by Eric Lightfoot on 2021-05-31.
//
import SwiftUI
import CoreLocation
import MapboxMaps

enum MapViewState:  Equatable {
    /// Starting state with (or without) user location
    /// Gesturing enabled (free/roaming)
    case base
    /// Constrained to focus on group of sprites
    case constrained([MapViewConstraintGroup])
    /// Current gesture
    case gesturing
    /// A cancellable animation is in progress
    case animating

    static func == (lhs: MapViewState, rhs: MapViewState) -> Bool {
        switch (lhs, rhs) {
            case (.constrained(let lha), .constrained(let rha)):
                return lha == rha
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

    func focusing () -> [FWMapSprite] {
        constraints().pan?.annotations() ?? []
    }
}

struct MapCameraState {
    var heading: Double
    var zoom: CGFloat
    var pitch: CGFloat
}

class MapController: ObservableObject {
    /// Map view state
    @Published var state: MapViewState = .base
    /// For interruptions of current state (caused
    /// by card view)
    private var previousState: MapViewState?

    @Published var camera = MapCameraState(heading: 0, zoom: 0, pitch: 0)
    @Published var cardHeight: CGFloat = .zero

    /// All annotations that are in .showing prop that are
    /// supposed to be kept in frame at one time
    var focusing: [FWMapSprite] {
        constraints.pan?.annotations() ?? []
    }
    /// Is not nil, the user has selected one annotation among
    /// what is available in .showing by tapping it
    var selectedByTap: FWMapSprite?

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
        state = .base
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
        constraintsQueue.append(group)
        state = .constrained(constraintsQueue)
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
    func interruptState (withState state: MapViewState) {
        previousState = state
        self.state = state
    }
    func endInterruption () {
        assert(previousState != nil, "map.endInterruption called without a current interruption")
        state = previousState!
        previousState = nil
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