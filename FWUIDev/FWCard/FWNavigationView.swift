//
// Created by Eric Lightfoot on 2021-05-18.
//

import SwiftUI

struct FWNavigationView<Content: View>: View {
    @Binding var cardState: FWCardState
    @Binding var headerHeight: CGFloat

    var content: () -> Content

    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                content()
                        .onChange(of: cardState) { _ in
                            headerHeight = proxy.safeAreaInsets.top
                        }
            }
        }
    }
}