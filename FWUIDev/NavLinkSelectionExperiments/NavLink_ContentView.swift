//
// Created by Eric Lightfoot on 2021-05-27.
//

import SwiftUI

enum Nav: String {
    case Root, Group, Detail
}

class Router: ObservableObject {
    @Published var _selection: Nav? = nil

    var selection: Binding<Nav?> {
        Binding<Nav?>(get: {
            self._selection
        }, set: {
            print("Router.selection = \(String(describing: $0))")
            self._selection = $0
        })
    }

    func setSelection (_ nav: Nav) {
        _selection = nav
    }
}

struct NavLink_ContentView: View {
    @StateObject var router = Router()
    var body: some View {
        NavigationView {
            RootView()
        }
                .environmentObject(router)
    }
}

struct RootView: View {
    @EnvironmentObject var router: Router

    var body: some View {
        ZStack {
            Color.yellow
            NavigationLink(
                    destination: GroupView(),
                    tag: Nav.Group,
                    selection: router.selection
            ) {
                Text("Group")
            }
        }
                .background(
                        NavigationLink(
                                destination: DetailView(),
                                tag: Nav.Detail,
                                selection: router.selection,
                                label: { EmptyView() }
                        )
                )
                .navigationBarTitle(Text("Root"), displayMode: .inline)
    }
}

struct GroupView: View {
    @EnvironmentObject var router: Router

    var body: some View {
        ZStack {
            Color.green
            NavigationLink(
                    destination: DetailView(),
                    tag: Nav.Detail,
                    selection: router.selection
            ) {
                Text("Detail")
            }
        }
                .navigationBarTitle(Text("Group"), displayMode: .inline)
    }
}

struct DetailView: View {
    @EnvironmentObject var router: Router

    var body: some View {
        ZStack {
            Color.purple
            VStack {
                Text("Detail")
            }
        }
                .navigationBarTitle(Text("Detail"), displayMode: .inline)
    }
}
