//
// Created by Eric Lightfoot on 2021-05-12.
//

import CoreGraphics

struct FWCard {
    /// Card size is exactly that of the container size
    /// which can change
    var size: CGSize = .zero

    /// Center is updated by gesture in FWCardView
    var center: CGPoint = .zero

    /// Screen coordinates of card
    var rect: CGRect = .zero

    /// Handle spec
    var handleHeight: CGFloat = 20.0

    /// Set card top in screen coordinates and
    /// keep center position computations internal
    var top: CGFloat {
        get {
            center.y - size.height / 2
        }
        set {
            setCenter(CGPoint(x: rect.width / 2, y: newValue + size.height / 2))
        }
    }

    private mutating func setCenter (_ pos: CGPoint) {
        center = pos
    }

    func position (forDragTranslation translation: CGSize) -> CGPoint {
        CGPoint(x: center.x, y: center.y + translation.height)
    }
}
