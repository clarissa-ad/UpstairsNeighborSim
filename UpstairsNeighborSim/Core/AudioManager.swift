import AVFoundation

class AudioManager {
    // 🌍 1. The Singleton
    static let shared = AudioManager()
    
    // 🔊 2. The Players
    // Player Pool: Prevents short sounds from cutting each other off
    private var sfxPlayers: [AVAudioPlayer] = []
    // Dedicated Looper: For continuous sounds like dragging
    private var scrapePlayer: AVAudioPlayer?
    
    private init() {
        setupScrapePlayer()
    }
    
    // 🧠 3. SUSTAINABILITY HELPER: Centralized file search logic
    private func getFileURL(for soundName: String, ext: String) -> URL? {
        // OPTION A: Look exactly where you specified
        if let strictPath = Bundle.main.url(forResource: soundName, withExtension: ext, subdirectory: "Assets/Sounds") {
            return strictPath
        }
        // OPTION B: Fallback if Xcode flattened the folders
        if let flatPath = Bundle.main.url(forResource: soundName, withExtension: ext) {
            return flatPath
        }
        return nil
    }
    
    // 💥 4. ONE-SHOT SOUNDS (Overlapping allowed!)
    func playSFX(_ soundName: String, ext: String = "mp3") {
        guard let finalURL = getFileURL(for: soundName, ext: ext) else {
            print("⚠️ AUDIO ERROR: Could not find \(soundName).\(ext)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: finalURL)
            player.play()
            
            sfxPlayers.append(player)
            // Memory cleanup: Remove players that have finished playing
            sfxPlayers.removeAll { !$0.isPlaying }
            
        } catch {
            print("⚠️ AUDIO ERROR: Failed to play \(soundName) - \(error.localizedDescription)")
        }
    }
    
    // 🪑 5. DEDICATED SCRAPE SETUP
    private func setupScrapePlayer() {
        // Try mp3 first, fallback to wav if needed
        guard let finalURL = getFileURL(for: "scrape", ext: "mp3") ?? getFileURL(for: "scrape", ext: "wav") else {
            print("⚠️ AUDIO ERROR: Could not find scrape audio file.")
            return
        }
        
        do {
            scrapePlayer = try AVAudioPlayer(contentsOf: finalURL)
            scrapePlayer?.numberOfLoops = 0 // 🛑 No infinite looping! It plays exactly once per request.
            scrapePlayer?.prepareToPlay()
        } catch {
            print("⚠️ AUDIO ERROR: Failed to setup scrape audio")
        }
    }
    
    // ▶️ THE SMART PLAY FUNCTION
    func playScrapeOnce() {
        // Only play if it is completely finished with its last scrape!
        if scrapePlayer?.isPlaying == false {
            scrapePlayer?.currentTime = 0 // Rewind to the very beginning of the sound
            scrapePlayer?.play()
        }
    }
    
    // 🛑 Hard kill-switch for when the mini-game completely ends
    func forceStopScrape() {
        scrapePlayer?.stop()
    }
}
