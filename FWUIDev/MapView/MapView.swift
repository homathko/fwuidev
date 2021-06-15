//
// Created by Eric Lightfoot on 2021-06-07.
//

import SwiftUI
import UIKit
import MapboxMaps

struct FWMapView: View {
    @StateObject var state: MapViewState
    @Binding var insets: UIEdgeInsets
    var annotations: [FWMapSprite]

    @State var visibleSprites = [FWMapSprite]()

    var body: some View {
        ZStack {
            MapboxViewRepresentable(state: state, insets: $insets) { updated in
                self.visibleSprites = []
                self.visibleSprites = updated
            }
                .styleURI(.myStyle)
                .annotations(annotations)

            ForEach(visibleSprites, id: \.id) { sprite in
                AnimatingSprite(sprite: sprite, position: sprite.point!)
            }
        }
    }
}
