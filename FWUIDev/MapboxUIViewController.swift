//
// Created by Eric Lightfoot on 2021-05-10.
//

    import UIKit
    import MapboxMaps

    class MapboxUIViewController: UIViewController {
        var mapView: MapView!
        var handler: ((MapboxCoreMaps.Event) -> Void)?

        override func viewDidLoad() {
            super.viewDidLoad()
            CredentialsManager.default.accessToken = "pk.eyJ1IjoiaHRlayIsImEiOiJja2gyZDB4Z3IwYW90MnNucHZ6aTN2N2g5In0.qOxZe7m1td1XTWkyIZCW-A"
            let mapView = MapView(frame: view.bounds)
            view.addSubview(mapView)


    // Add terrain
            var demSource = RasterDemSource()
            demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
            demSource.tileSize = 512
            demSource.maxzoom = 14.0
            try! mapView.style.addSource(demSource, id: "mapbox-dem")

            var terrain = Terrain(sourceId: "mapbox-dem")
            terrain.exaggeration = .constant(1.5)

    // Add sky layer
            try! mapView.style.setTerrain(terrain)

            var skyLayer = SkyLayer(id: "sky-layer")
            skyLayer.paint?.skyType = .constant(.atmosphere)
            skyLayer.paint?.skyAtmosphereSun = .constant([0.0, 0.0])
            skyLayer.paint?.skyAtmosphereSunIntensity = .constant(15.0)

            try! mapView.style.addLayer(skyLayer)
        }
    }
