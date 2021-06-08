//
// Created by Eric Lightfoot on 2021-06-04.
//

import SwiftUI

struct AnimatingSprite: View {
    var sprite: FWMapSprite

    @State private var opacity = 0.4
    @State private var scale: CGFloat = 0.5

    var body: some View {
        ZStack {
            Circle()
                    .fill(sprite.spriteType == .asset ? Color.green : Color.blue)
                    .frame(width: 20, height: 20).scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(repeatingAnimation) {
                            self.opacity = 1.0
                            self.scale = 2.5
                        }
                    }
            Text(sprite.title ?? "")
                    .foregroundColor(.white)
                    .font(.system(size: 13))
                    .scaleEffect(scale)
        }
                .position(sprite.point!)
    }

    var repeatingAnimation: Animation {
        Animation
                .easeIn(duration: Double.random(in: 0.4...1.8))
                .repeatForever()
    }
}
