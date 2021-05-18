//
//  SafeAreaInsetBorder.swift
//  GeometryProxyExperiments
//
//  Created by Eric Lightfoot on 2021-05-18.
//

import SwiftUI

struct SafeAreaInsetsView: View {
    var body: some View {
        GeometryReader { proxy in
            VStack {
                HStack {
                    Spacer()
                    labelView(proxy.safeAreaInsets.top)
                    Spacer()
                }
                Spacer()
                HStack {
                    labelView(proxy.safeAreaInsets.leading)
                    Spacer()
                    labelView(proxy.safeAreaInsets.trailing)
                }
                Spacer()
                HStack {
                    Spacer()
                    labelView(proxy.safeAreaInsets.bottom)
                    Spacer()
                }
            }
        }
    }
    
    func labelView (_ value: CGFloat) -> some View {
        Text("\(Int(value)) pts")
            .font(.caption2)
            .border(Color.blue)
            .background(Color.white)
    }
}

struct SafeAreaInsetView_Previews: PreviewProvider {
    static var previews: some View {
        SafeAreaInsetsView()
    }
}
