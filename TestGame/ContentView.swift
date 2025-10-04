//
//  ContentView.swift
//  TestGame
//
//  Created by Edward Gasparian on 03.10.2025.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 390, height: 844)
        scene.scaleMode = .resizeFill
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
