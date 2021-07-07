//
// Created by Eric Lightfoot on 2021-06-07.
//

import SwiftUI
import UIKit
import MapboxMaps

struct FWMapView: View {
    @ObservedObject var map: MapController
    var annotations: [FWMapSprite]
    @Binding var cardTop: CGFloat
    @State private var visibleSprites = [FWMapSprite]()

    var body: some View {
        ZStack {
            MapboxViewRepresentable(controller: map, cardTop: $cardTop) { updated in
                self.visibleSprites = []
                self.visibleSprites = updated
            }
                .styleURI(.myStyle)
                .annotations(annotations)

            ForEach(visibleSprites, id: \.id) { sprite in
                AnimatingSprite(
                        sprite: sprite,
                        position: sprite.point!
                )
            }
        }
            .environmentObject(map)
    }
}
