//
// Created by Eric Lightfoot on 2021-05-12.
//

import CoreGraphics
import SwiftUI

extension FWCardView {
    struct DragHandle: View {
        private let handleThickness = CGFloat(5.0)
        var body: some View {
            RoundedRectangle(cornerRadius: handleThickness / 2.0)
                    .frame(width: 40, height: handleThickness)
                    .foregroundColor(.white)
                    .opacity(0.5)
                    .padding(5)
        }
    }
}
