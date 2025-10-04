//
//  MainMenu.swift
//  TestGame
//
//  Created by Edward Gasparian on 04.10.2025.
//
//
//  MainMenu.swift
//  TestGame
//
//  Created by Edward Gasparian on 04.10.2025.
//
//  ----------------------------------------------------
//  MainMenuView
//  ----------------------------------------------------
//  This file defines the **main menu screen** of the game.
//
//  Responsibilities:
//  - Display the game title.
//  - Provide navigation to:
//      • Start Game (opens GameContainerView in full screen).
//      • High Scores (navigates to ScoreRecordsView).
//      • Settings (navigates to SettingsView).
//  - Play button click sounds via AudioManager.
//  - Control background music (menu theme), respecting the
//    "musicPlay" setting stored in @AppStorage.
//  - Render a background image ("MenuIMG") that fills the screen.
//
//  UI Notes:
//  - Uses NavigationStack for navigation between views.
//  - Custom reusable button style implemented via `menuButtonLabel()`.
//  - Layout is adaptive with spacing and safe area handling.
//
//  Scene flow:
//  1. On appear, if musicPlay == true → play menu music.
//  2. User selects one of the options (Start, High Scores, Settings).
//  3. Correct screen/view is opened accordingly.
//

import SwiftUI

struct MainMenuView: View {
    @State private var showGame = false
    @AppStorage("musicPlay") private var musicPlay = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                
                // MARK: - Game Title
                Text("Space Game")
                    .font(.largeTitle).bold()
                    .foregroundStyle(.white)
                    .padding(.top, 16)
                
                Spacer(minLength: 8)
                
                // MARK: - Start button
                Button {
                    AudioManager.shared.playSFX(name: "buttonClicked")
                    showGame = true
                } label: {
                    menuButtonLabel("🎮 Start Game")
                }
                .buttonStyle(.plain)
                .fullScreenCover(isPresented: $showGame) {
                    GameContainerView()
                }
                
                // MARK: - High scores button
                NavigationLink {
                    ScoreRecordsView()
                } label: {
                    menuButtonLabel("🏆 High Scores", bg: .white)
                }
                .buttonStyle(.plain)
                .simultaneousGesture(TapGesture().onEnded {
                    AudioManager.shared.playSFX(name: "buttonClicked")
                })
                
                // MARK: - Settings button
                NavigationLink {
                    SettingsView()
                } label: {
                    menuButtonLabel("⚙️ Settings", bg: .white)
                }
                .buttonStyle(.plain)
                .simultaneousGesture(TapGesture().onEnded {
                    AudioManager.shared.playSFX(name: "buttonClicked")
                })
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .background(
                Image("MenuIMG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
        }
        // MARK: - Play menu music on appear (if enabled)
        .onAppear {
            if musicPlay {
                AudioManager.shared.playMusic(name: "menuTrack")
            }
        }
    }
    
    // MARK: - Reusable button label
    /// Creates a reusable styled label for menu buttons.
    ///   - Parameters:
    ///   - title: Button text.
    ///   - bg: Background color (default: white).
    private func menuButtonLabel(_ title: String,
                                 bg: Color = .white) -> some View {
        Text(title)
            .font(.title2).bold()
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(bg)
                    .shadow(radius: 6, y: 3)
            )
            .foregroundStyle(.black)
            .contentShape(Rectangle()) // ensures tappable area
    }
}

#Preview {
    MainMenuView()
}
