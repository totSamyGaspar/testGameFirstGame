//
//  GameContainerView.swift
//  TestGame
//
//  Created by Edward Gasparian on 04.10.2025.
//
import SwiftUI
import SpriteKit

struct GameContainerView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geo in
            SpriteView(scene: {
                let scene = GameScene(size: geo.size)
                scene.scaleMode = .resizeFill
                return scene
            }())
            .ignoresSafeArea()
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("exitToMenu"))) { _ in
                dismiss()
            }
        }
    }
}

#Preview {
    GameContainerView()
}
