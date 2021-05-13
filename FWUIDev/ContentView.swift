//
//  ContentView.swift
//  FWUIDev
//
//  Created by Eric Lightfoot on 2021-05-10.
//

import SwiftUI

struct InsideTabViewFrame: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce (value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct InsideDraggableCardViewFrame: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce (value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ContentView: View {
    @State var viewFrame: CGRect = .zero
    @State var detents: CardDetents = .init()
    @State var tab: Int = 0

    var body: some View {
        TabView(selection: $tab) {
            GeometryReader { insideTabView in
                ZStack {
                    Color.blue
                    DraggableSlideOverCard(detents: $detents, viewableProxy: insideTabView) {
                        NavigationView {
                            YellowView()
                        }
                                .navigationViewStyle(StackNavigationViewStyle())
                    } onFrameChange: { rect, dragging in

                    }
                }
                        .preference(key: InsideTabViewFrame.self, value: insideTabView.frame(in: CoordinateSpace.global))
            }
                    .onPreferenceChange(InsideTabViewFrame.self) { viewFrame in
                        self.viewFrame = viewFrame
                    }
                    /// View inside TabView frame
                    .overlay(
                            Color.clear.border(Color.red)
                                    .frame(width: viewFrame.width, height: viewFrame.height)
                    )
                    .tabItem {
                        Group {
                            Image(systemName: "radiowaves.left")
                            Text("Tab 1")
                        }
                    }
                    .tag(0)
        }
    }
}

struct YellowView: View {
    var body: some View {
        NavigationLink(destination: GreenView()) {
            ZStack {
                Color.yellow
                        .navigationBarTitle("Yellow", displayMode: .inline)
                VStack {
                    Color.clear.border(Color.green)
                            .frame(height: 200)
//                            .markDetent(.partial)
                    Spacer()
                }
            }

        }
    }
}

struct GreenView: View {
    var body: some View {
        NavigationLink(destination: RedView()) {
            ZStack {
                Color.green
                        .navigationBarTitle("Green", displayMode: .inline)
                VStack {
                    Color.clear.border(Color.black)
                            .frame(height: 100)
//                            .markDetent(.partial)
                    Spacer()
                }
            }
        }
    }
}

struct RedView: View {
    var body: some View {
        NavigationLink(destination: Color.black) {
            Color.red
                    .navigationBarTitle("Red", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
