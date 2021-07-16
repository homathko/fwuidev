//
// Created by Eric Lightfoot on 2021-05-12.
//

import Foundation

public enum FWCardState: String {
    case collapsed, partial, full
}

public enum FWCardTransitionState {
    case idle, gesturing, animating
}