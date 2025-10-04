//
//  MainMenu.swift
//  TestGame
//
//  Created by Edward Gasparian on 04.10.2025.
//

import SwiftUI

struct MainMenuView: View {
    @State private var showGame = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Test Game")
                    .font(.largeTitle)
                    .bold()
                
                Button("🎮 Start Game") {
                    showGame = true
                }
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .fullScreenCover(isPresented: $showGame) {
                    GameContainerView()
                }
                
                NavigationLink(destination: ScoreRecords()) {
                    Text("🏆 High Scores")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                NavigationLink(destination: SettingsView()) {
                    Text("⚙️ Settings")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    MainMenuView()
}
