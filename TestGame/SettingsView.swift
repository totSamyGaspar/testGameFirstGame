//
//  SettingsView.swift
//  TestGame
//
//  Created by Edward Gasparian on 04.10.2025.
//
//  ----------------------------------------------------
//  SettingsView
//  ----------------------------------------------------
//  This file defines the settings screen of the game.
//
//  Responsibilities:
//  - Allow the player to enable/disable background music.
//  - Allow the player to enable/disable sound effects (SFX).
//  - Persist these preferences across app launches using
//    @AppStorage (backed by UserDefaults).
//  - Automatically start/stop menu music when the music
//    toggle changes.
//
//  UI Notes:
//  - Uses SwiftUI Form with Toggle switches.
//  - Toggles are bound to `musicPlay` and `sfxPlay` values.
//  - AudioManager is used to control background music playback.
//
//  Scene flow:
//  1. User opens SettingsView.
//  2. Toggles "Music" or "Sounds".
//  3. Changes are instantly saved and applied globally
//     (music is started/stopped immediately).
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("musicPlay") private var musicPlay = true
    @AppStorage("sfxPlay") private var sfxPlay = true
    
    var body: some View {
        Form {
            Toggle("Music:", isOn: $musicPlay)
            Toggle("Sounds", isOn: $sfxPlay)
        }
        .onChange(of: musicPlay) { oldValue, newValue in
            if newValue {
                AudioManager.shared.playMusic(name: "menuTrack")
            } else {
                AudioManager.shared.stopMusic()
            }
        }
    }
}
