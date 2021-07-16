//
// Created by Eric Lightfoot on 2021-06-17.
// Copyright (c) 2021 HomathkoTech. All rights reserved.
//

import SwiftUI

struct SpriteView: View {
    @EnvironmentObject var map: MapController
    var sprite: FWMapSprite
    @State var isSelected: Bool = false

    @State private var opacity = 0.6
    @State private var scale: CGFloat = 0.5

    var body: some View {
        ZStack {
            if isSelected {
                whitePulse
            }
            /// Accentuating graphics layers below sprite view
            view(sprite, totalRotation)
        }
        .onTapGesture {
            print("Tapped \(sprite.title ?? "n/a")")
            map.selectedByTap = sprite
        }
        .onChange(of: map.selectedByTap) { selected in
            isSelected = selected == sprite
        }
    }

    private func view (_ sprite: FWMapSprite, _ rotation: Double) -> some View {
        Group {
            switch sprite.spriteType {
                case .asset:
                    AssetSprite(sprite: sprite, rotation: totalRotation)
                case .user:
                    UserSprite()
                default:
                    Circle().fill(Color.red).frame(width: 20, height: 20)
            }
        }
    }

    var whitePulse: some View {
        Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20).scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(repeatingAnimation) {
                        self.opacity = 0.2
                        self.scale = 2.5
                    }
                }
    }

    var repeatingAnimation: Animation {
        Animation
                .easeIn(duration: 0.5)
                .repeatForever(autoreverses: true)
    }

    var totalRotation: Double {
        switch sprite.rotationModifier {
            case .none: return map.camera.heading
            case .alwaysUp: return 0.0
            case .heading(let value): return Double(value) - map.camera.heading
        }
    }
}

struct UserSprite: View {
    @State var whiteCircleDiameter: CGFloat = 18
    @State var pulseDiameter: CGFloat = 20
    @State var pulseOpacity: Double = 0.6

    var body: some View {
        ZStack {
            Circle().fill(Color.white)
                    .frame(width: pulseDiameter, height: pulseDiameter)
                    .opacity(pulseOpacity)
                    .onAppear {
                        withAnimation(repeatingAnimation(reverse: false)) {
                            pulseDiameter = 65
                            pulseOpacity = 0
                        }
                    }
            Circle().fill(Color.white)
                    .frame(width: whiteCircleDiameter, height: whiteCircleDiameter)
                    .onAppear {
                        withAnimation(repeatingAnimation(reverse: true)) {
                            whiteCircleDiameter = 23
                        }
                    }
            Circle().fill(Color.accentColor)
                    .frame(width: 15, height: 15)
        }
    }

    func repeatingAnimation (reverse: Bool) -> Animation {
        Animation
                .easeOut(duration: 2.0)
                .repeatForever(autoreverses: reverse)
    }
}

struct AssetSprite: View {
    var sprite: FWMapSprite
    var rotation: Double

    var body: some View {
        print(rotation)
        return ZStack {
            VStack {
                VStack {
                    Text(sprite.shouldDisplayAltitude ? altitude : "")
                    Text(sprite.shouldDisplaySpeed ? speed : "")
                }.padding(.bottom, -8)

                Image(systemName: sprite.isTransmitting ? "location.north.fill" : "location.north")
                        .frame(width: 30, height: 30)
                        .scaleEffect(1.8)
                        .rotationEffect(.degrees(rotation), anchor: sprite.anchorPoint)
                        .offset(y: -7)

                Text(sprite.title ?? "")
            }

        }
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 100, height: 100)
                .shadow(color: .black, radius: 10)
                /// Make tappable area large
                .contentShape(Rectangle())
    }

    var altitude: String {
        "\(sprite.location.altitude)'"
    }

    var speed: String {
        if let spd = sprite.speed {
            return "\(spd)KTS"
        } else {
            return ""
        }
    }
}

struct SpriteView_Preview: PreviewProvider {
    
    static var previews: some View {
        UserSprite()
            .position(x: 100, y: 100)
            .background(Color.black)
    }
}
