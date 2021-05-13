//
// Created by Eric Lightfoot on 2021-05-12.
//

import UIKit

extension CGSize {
    var yComponent: CGSize {
        CGSize(width: 0.0, height: height)
    }

    func yComponent (onlyGreaterThan floor: CGFloat) -> CGSize {
        CGSize(width: 0.0, height: max(height, floor))
    }

    func yComponent (onlyLessThan ceiling: CGFloat) -> CGSize {
        CGSize(width: 0.0, height: min(height, ceiling))
    }
}