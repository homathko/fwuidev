//
// Created by Eric Lightfoot on 2021-07-26.
//

import SwiftUI

/// Use AnimationProgressObserverModifier by passing an
/// animatable property along with a closure to execute
/// whenever that property is changed throughout the
/// animation
struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {
    var targetValue: Value
    /// The animatable property to be observed
    /// passed in at init
    var animatableData: Value {
        didSet {
            check()
        }
    }

    /// The block to execute on each animation progress
    /// update
    private var onCompletion: () -> Void

    init (observedValue: Value, onCompletion: @escaping () -> Void) {
        animatableData = observedValue
        targetValue = observedValue
        self.onCompletion = onCompletion
    }

    func check () {
        if (animatableData == targetValue) {
            DispatchQueue.main.async {
                onCompletion()
            }
        }
    }

    func body (content: Content) -> some View {
        /// No modification to view content
        content
            .animation(nil)
    }
}

extension View {
    /// Convenience method on View
    func onCompletion<Value: VectorArithmetic> (for value: Value, onCompletion: @escaping () -> Void)
                    -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        modifier(AnimationCompletionObserverModifier(observedValue: value, onCompletion: onCompletion))
    }
}
