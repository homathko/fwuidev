//
// Created by Eric Lightfoot on 2021-06-24.
//

import SwiftUI

/// Use AnimationProgressObserverModifier by passing an
/// animatable property along with a closure to execute
/// whenever that property is changed throughout the
/// animation
struct AnimationProgressObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {

    /// Some experimenting led to observing the behaviour
    /// that wrapping the observedValue with animatableData
    /// (to conform to the protocol) caused this property
    /// to be set continuously during the animation, instead
    /// of only at the end
    var animatableData: Value {
        get {
            observedValue
        }
        set {
            observedValue = newValue
            runCallbacks()
        }
    }

    /// The animatable property to be observed
    /// passed in at init
    private var observedValue: Value

    /// The block to execute on each animation progress
    /// update
    private var onBody: (Value) -> Void

    init (observedValue: Value, onBody: @escaping (Value) -> Void) {
        self.onBody = onBody
        self.observedValue = observedValue
    }

    /// Run the onBody block provided at init
    /// specifically passing animatable data,
    /// NOT observedValue
    private func runCallbacks () {
        DispatchQueue.main.async {
            onBody(animatableData)
        }
    }

    func body (content: Content) -> some View {
        /// No modification to view content
        content
    }
}

extension View {
    /// Convenience method on View
    func onBody<Value: VectorArithmetic> (for value: Value, onBody: @escaping (Value) -> Void)
                    -> ModifiedContent<Self, AnimationProgressObserverModifier<Value>> {
        modifier(AnimationProgressObserverModifier(observedValue: value, onBody: onBody))
    }
}
