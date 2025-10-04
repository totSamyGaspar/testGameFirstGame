//
//  MainMenu.swift
//  TestGame
//
//  Created by Edward Gasparian on 04.10.2025.
//
//  ----------------------------------------------------
//  MainMenuView
//  ----------------------------------------------------
//  This file defines the main menu screen of the game.
//
//  Responsibilities:
//  - Display the game title and main navigation options.
//  - Provide entry points to:
//      • Start Game (opens GameContainerView in full screen).
//      • High Scores (navigates to ScoreRecords).
//      • Settings (navigates to SettingsView).
//  - Play button click sounds via AudioManager.
//  - Control background music (menu theme), respecting the
//    musicPlay user setting (stored in @AppStorage).
//  - Render a background image ("MenuIMG") that fills the screen.
//
//  UI Notes:
//  - Uses NavigationStack for navigation between views.
//  - Custom buttons styled with `.glass` for consistency.
//  - Buttons trigger sound effects when tapped.
//  - Layout adapts across devices with flexible frames and spacers.
//
//  Scene flow:
//  1. On appear, if musicPlay == true => play menu music.
//  2. User selects one of the options (Start, High Scores, Settings).
//  3. Correct screen/view is opened accordingly.
//

import SwiftUI
import AVFoundation

struct MainMenuView: View {
    @State private var showGame = false
    @AppStorage("musicPlay") private var musicPlay = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Space Game")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white)
                
                Spacer()
                Button {
                    AudioManager.shared.playSFX(name: "buttonClicked")
                    showGame = true
                } label: {
                    Text("🎮 Start Game")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(.glass)
                .fullScreenCover(isPresented: $showGame) {
                    GameContainerView()
                }
                
                NavigationLink(destination: ScoreRecords()) {
                    Text("🏆 High Scores")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                .buttonStyle(.glass)
                .simultaneousGesture(TapGesture().onEnded {
                    AudioManager.shared.playSFX(name: "buttonClicked")
                })
                
                NavigationLink(destination: SettingsView()) {
                    Text("⚙️ Settings")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                .buttonStyle(.glass)
                .simultaneousGesture(TapGesture().onEnded {
                    AudioManager.shared.playSFX(name: "buttonClicked")
                })
                
                Spacer()
            }
            .padding()
            .background(
                Image("MenuIMG")
                    .resizable()
                    .ignoresSafeArea()
            )
        }
        .onAppear {
            if musicPlay {
                AudioManager.shared.playMusic(name: "menuTrack")
            }
        }
    }
}

#Preview {
    MainMenuView()
}
