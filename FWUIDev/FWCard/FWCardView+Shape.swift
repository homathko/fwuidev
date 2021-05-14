//
// Created by Eric Lightfoot on 2021-05-14.
//

import SwiftUI

extension FWCardView {

    struct CardShape: ViewModifier {
        var cardState: FWCardState

        func body (content: Content) -> some View {
            Group {
                if cardState != .full {
                    content
                            .cornerRadius(10.0, corners: [.topLeft, .topRight])
                            .padding(.leading, 4).padding(.trailing, 4)
                            .edgesIgnoringSafeArea(.bottom)
                } else {
                    content.edgesIgnoringSafeArea(.all)
                }
            }
        }
    }
}
