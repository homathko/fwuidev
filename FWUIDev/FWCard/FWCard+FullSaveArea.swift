//
// Created by Eric Lightfoot on 2021-05-18.
//

import SwiftUI


struct TopSafeArea_Preview: PreviewProvider {

    static var previews: some View {
            FWCardView(cardState: .constant(.full),
                    detentHeight: .constant(200),
                    headerHeight: .constant(0))
            {
                Color.pink
            }
    }
}
