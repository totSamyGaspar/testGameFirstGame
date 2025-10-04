//
//  AudioManager.swift
//  TestGame
//
//  Created by Edward Gasparian on 04.10.2025.
//

import Foundation
import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var musicPlayer: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?
    
    // Plays background music in an infinite loop, if enabled in settings
    func playMusic(name: String) {
        // Check if music is enabled
        guard UserDefaults.standard.bool(forKey: "musicPlay"),
              let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.play()
        } catch {
            print("Music error: \(error.localizedDescription)")
        }
    }
    
    // Stops the currently playing background music
    func stopMusic() {
        musicPlayer?.stop()
    }
    
    // Plays one-shot sound effect, if enabled in settings
    func playSFX(name: String) {
        guard UserDefaults.standard.bool(forKey: "sfxPlay"),
              let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.play()
        } catch {
            print("SFX error: \(error.localizedDescription)")
        }
    }
}
