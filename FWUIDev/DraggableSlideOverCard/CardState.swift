//
// Created by Eric Lightfoot on 2020-10-22.
// Copyright (c) 2020 HomathkoTech. All rights reserved.
//

import SwiftUI

public enum CardState {
    case full
    case partial
    case collapsed

    func height(_ detents: CardDetents) -> CGFloat {
        switch self {
            case .full:
                return detents[.full]
            case .partial:
                return detents[.partial]
            case .collapsed:
                return detents[.collapsed]
        }
    }

    mutating func setState(_ detents: CardDetents, forHeight h: CGFloat) {
        if Int(h) == Int(detents[.full]) { self = .full }
        else if Int(h) == Int(detents[.partial]) { self = .partial }
        else if Int(h) == Int(detents[.collapsed]) { self = .collapsed }
    }
}

struct CardDetents {
    var height: [CardState: CGFloat] = [
        .full: UIScreen.main.bounds.height - 200,
        .partial: UIScreen.main.bounds.height / 2,
        .collapsed: 0
//        .full: /*UIScreen.main.bounds.height / 5*/128,
//        .partial: UIScreen.main.bounds.height / 2,
//        .collapsed: UIScreen.main.bounds.height - 150
    ]

    var `default`: CardState = .collapsed

    private var safeFullHeight: CGFloat { height[.full] ?? height[.partial] ?? height[.collapsed]! }
    private var safePartialHeight: CGFloat { height[.partial] ?? height[.collapsed]! }

    subscript (state: CardState) -> CGFloat {
        get {
            switch state {
                case .full:
                    return safeFullHeight
                case .partial:
                    return safePartialHeight
                case .collapsed:
                    return height[.collapsed]!
            }
        }
        set {
            height[state] = newValue

            /// Limit the next highest screen height to the same height if required
            if let partialHeight = height[.partial], let fullHeight = height[.full] {
                if partialHeight > fullHeight {
                    height[.partial] = fullHeight
                }
            }
            if let collapsedHeight = height[.collapsed], let partialHeight = height[.partial] {
                if collapsedHeight > partialHeight {
                    height[.collapsed] = partialHeight
                }
            }
        }
    }

    init () { }

    init (heights: [CardState: CGFloat], `default`: CardState = .collapsed) {
        height = merge(dict: heights)
        self.default = `default`
    }

    init (state: CardState, height: CGFloat) {
        self.height[state] = height
    }

    func merge (dict: [CardState: CGFloat]) -> [CardState: CGFloat] {
        var merged: [CardState: CGFloat] = [.collapsed: UIScreen.main.bounds.height - 200]

        _ = dict.map { key, value in
            merged[key] = value
        }

        return merged
    }

    func cardCenter (state: CardState) -> CGPoint {
        CGPoint(
                x: UIScreen.main.bounds.width / 2,
                y: height[state]! + _cardHeight / 2
        )
    }
}

extension View {
    func markDetent (_ state: CardState) -> some View {
        self.modifier(MarkDetent(state: state))
    }
}

struct MarkDetent: ViewModifier {
    var state: CardState

    func body(content: Content) -> some View {
        return content.background(FrameHeightGetter(state: state))
    }
}

struct FrameHeightGetter: View {
    var state: CardState

    var body: some View {
        GeometryReader { proxy in
            Color(.clear).preference(
                    key: DraggableSlideOverCardPositionPreferenceKey.self,
                    value: DraggableSlideOverCardPositionInfo(
                            state: state,
                            height: proxy.frame(in: .global).height
                    )
            )
        }
    }
}

struct DraggableSlideOverCardPositionInfo: Equatable {
    var state: CardState
    var height: CGFloat
}

struct DraggableSlideOverCardPositionPreferenceKey: PreferenceKey {
    static var defaultValue: DraggableSlideOverCardPositionInfo = .init(state: .collapsed, height: 0)

    static func reduce(value: inout DraggableSlideOverCardPositionInfo, nextValue: () -> DraggableSlideOverCardPositionInfo) {
        value = nextValue()
    }
}

