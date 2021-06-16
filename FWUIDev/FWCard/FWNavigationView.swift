//
// Created by Eric Lightfoot on 2021-05-18.
//

import Foundation
import SwiftUI

struct FWNavigationView<Content: View>: UIViewControllerRepresentable, Equatable {
    static func == (lhs: FWNavigationView<Content>, rhs: FWNavigationView<Content>) -> Bool {
        true
    }

    @Binding var cardState: FWCardState
    @Binding var headerHeight: CGFloat

    var content: () -> Content

    func makeUIViewController (context: Context) -> UINavigationController {
        let viewController = UINavigationController()
        viewController.setViewControllers([UIHostingController(rootView: content())], animated: false)
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController (_ uiViewController: UINavigationController, context: Context) {
        self.headerHeight = uiViewController.navigationBar.frame.height
    }

    func makeCoordinator () -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate {
        var parent: FWNavigationView

        init(_ controller: FWNavigationView) {
            parent = controller
        }

        func navigationController (_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//            dump(navigationController)
        }
    }
}

//struct FWNavigationView<Content: View>: View {
//    @Binding var cardState: FWCardState
//    @Binding var headerHeight: CGFloat
//
//    var content: () -> Content
//
//    var body: some View {
//        NavigationView {
//            GeometryReader { proxy in
//                content()
//                        .onChange(of: cardState) { _ in
//                            headerHeight = proxy.safeAreaInsets.top
//                        }
//            }
//        }
//    }
//}