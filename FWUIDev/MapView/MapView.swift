//
// Created by Eric Lightfoot on 2021-06-07.
//

import SwiftUI
import UIKit
import MapboxMaps

struct FWMapView: View {
    @EnvironmentObject var state: MapViewState
    @Binding var insets: UIEdgeInsets
    var annotations: [Annotation & Locatable & FWMapScreenDrawable]

    @State var visibleSprites: [FWMapSprite] = []

    var body: some View {
        ZStack {
            MapboxViewRepresentable(insets: $insets) { mapViewCoordinator in
                DispatchQueue.main.async(qos: .userInteractive) {
                    visibleSprites = mapViewCoordinator.annotations
                            .map {
                                var result = $0
                                result.point = mapViewCoordinator.mapView?.mapboxMap.point(for: $0.location.coordinate)
                                return result as! FWMapSprite
                            }
                }
            }
                .styleURI(.myStyle)
                .annotations(annotations)

            ForEach(visibleSprites, id: \.id) { sprite in
                AnimatingSprite(sprite: sprite)
            }
        }
    }
}
