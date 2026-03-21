import AVFoundation

class AudioManager {
    // 1. The Singleton
    static let shared = AudioManager()
    
    // 2. The Player Pool (Prevents sounds from cutting off instantly)
    private var sfxPlayers: [AVAudioPlayer] = []
    
    private init() {}
    
    // 3. The Play Function (Now aware of your custom directory!)
    func playSFX(_ soundName: String, ext: String = "mp3") {
        var fileURL: URL?
        
        // OPTION A: Look exactly where you told me to (Assets/Sounds)
        if let strictPath = Bundle.main.url(forResource: soundName, withExtension: ext, subdirectory: "Assets/Sounds") {
            fileURL = strictPath
        }
        // OPTION B: Fallback if Xcode flattened the Yellow Folders
        else if let flatPath = Bundle.main.url(forResource: soundName, withExtension: ext) {
            fileURL = flatPath
        }
        
        // 4. Catch missing files
        guard let finalURL = fileURL else {
            print("⚠️ AUDIO ERROR: Could not find \(soundName).\(ext) in UrUpstairsNeighborSim/Assets/Sounds/ or the main bundle.")
            return
        }
        
        // 5. Play the sound
        do {
            let player = try AVAudioPlayer(contentsOf: finalURL)
            player.play()
            
            sfxPlayers.append(player)
            sfxPlayers.removeAll { !$0.isPlaying } // Memory cleanup
            
        } catch {
            print("⚠️ AUDIO ERROR: Failed to play \(soundName) - \(error.localizedDescription)")
        }
    }
}
