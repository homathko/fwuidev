//
// Created by Eric Lightfoot on 2021-06-07.
//

import SwiftUI
import UIKit
import MapboxMaps

struct FWMapView: View {
    var map: MapController
    @Binding var annotations: [FWMapSprite]
    @Binding var cardTop: CGFloat
    var bottomInset: CGFloat
    @State private var visibleSprites = [FWMapSprite]()

    var body: some View {
        ZStack {
            MapboxViewRepresentable(controller: map, cardTop: $cardTop, bottomInset: bottomInset) { updated in
                self.visibleSprites = []
                self.visibleSprites = updated
            }
                .styleURI(.myStyle)
                .annotations(annotations)

            ForEach(visibleSprites, id: \.id) { sprite in
                    SpriteView(sprite: sprite)
                            .position(sprite.point!)
                            .animation(
                                    map.state == .gesturing || map.state == .animating ?
                                            .linear(duration: 0.1) : .linear(duration: 1.0)
                            )
                            .environmentObject(map)
            }
        }
    }
}
