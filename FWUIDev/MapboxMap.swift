//
// Created by Eric Lightfoot on 2021-05-10.
//

import SwiftUI
import MapboxMaps

struct MapboxMap: UIViewControllerRepresentable {


    func makeUIViewController(context: Context) -> MapboxUIViewController {
        let vc = MapboxUIViewController()

        return vc
    }

    func updateUIViewController(_ uiViewController: MapboxUIViewController, context: Context) {}
}


