//
// Created by Eric Lightfoot on 2020-10-22.
// Copyright (c) 2020 HomathkoTech. All rights reserved.
//

import SwiftUI

public enum DragState {
    case inactive
    case dragging(translation: CGSize)

    var translation: CGSize {
        switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
        }
    }

    var isDragging: Bool {
        switch self {
            case .inactive:
                return false
            case .dragging:
                return true
        }
    }
}
