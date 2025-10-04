//
//  GameContainerView.swift
//  TestGame
//
//  Created by Edward Gasparian on 04.10.2025.
//
//  ----------------------------------------------------
//  GameContainerView
//  ----------------------------------------------------
//  This view serves as a SwiftUI container for the SpriteKit game scene.
//
//  Responsibilities:
//  - Embeds `GameScene` inside SwiftUI using `SpriteView`.
//  - Passes the correct size to the scene using `GeometryReader`.
//  - Handles dismissal back to the main menu when receiving the
//    "exitToMenu" notification from GameScene.
//
//  UI Notes:
//  - `.ignoresSafeArea()` is applied so the game takes the full screen.
//  - Uses @Environment(\.dismiss) to allow navigation back to menu.
//  - NotificationCenter is used to decouple SpriteKit scene logic
//    from SwiftUI navigation logic.
//
//  Scene flow:
//  1. MainMenuView launches GameContainerView via fullScreenCover.
//  2. GameContainerView initializes GameScene with the correct size.
//  3. GameScene posts "exitToMenu" when player chooses Main Menu.
//  4. GameContainerView receives notification and calls dismiss().
//

import SwiftUI
import SpriteKit

struct GameContainerView: View {
    // Environment dismiss => allows closing this view and returning to MainMenuView
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geo in
            // Embed SpriteKit scene inside SwiftUI
            SpriteView(scene: {
                // Create new GameScene sized to the current screen (geo.size)
                let scene = GameScene(size: geo.size)
                scene.scaleMode = .resizeFill   // Adjusts automatically to fit screen
                return scene
            }())
            .ignoresSafeArea() // Game takes the whole screen, ignores safe areas
            
            // Listen for Notification "exitToMenu" (posted from GameScene)
            // If received, call dismiss() to close game and return to menu
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("exitToMenu"))) { _ in
                dismiss()
            }
        }
    }
}

#Preview {
    GameContainerView()
}
