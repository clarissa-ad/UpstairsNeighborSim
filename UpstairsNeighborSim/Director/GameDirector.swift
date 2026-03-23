import SwiftUI
import Combine

// 1. THE DATABASE: Centralized Metadata for all games
enum MiniGame: CaseIterable {
    case stomp, snooze, party, dj, cymbals, furniture, bonus
    
    static var normalGames: [MiniGame] {
        return [.stomp, .snooze, .party, .dj, .cymbals, .furniture]
    }
    
    var instruction: String {
        switch self {
        case .stomp: return "STOMP!"
        case .snooze: return "SNOOZE!"
        case .party: return "WAVE!"
        case .dj: return "SCRATCH!"
        case .cymbals: return "CLAP!"
        case .furniture: return "PINCH & GRAB!"
        case .bonus: return "BONUS STAGE!"
        }
    }
    
    var timeLimit: Double {
        switch self {
        case .snooze: return 7.0
        case .bonus: return 9.0
        default: return 5.0
        }
    }
}

// 2. THE REFEREE: Manages the clock and the game flow
class GameDirector: ObservableObject {
    @Published var currentGame: MiniGame = .stomp
    @Published var timeRemaining: Double = 5.0
    
    // 🔧 SEQUENCE SETTINGS
    @Published var isSequenceComplete: Bool = false
    @Published var isPaused: Bool = false // ⏸️ NEW: Tracks if the game is paused
    var totalSequenceLength: Int = 5
    private var gamesPlayed: Int = 0
    
    private var timerCancellable: AnyCancellable?
    
    func start(rounds: Int = 5) {
        self.totalSequenceLength = rounds
        self.gamesPlayed = 0
        self.isSequenceComplete = false
        self.isPaused = false
        pickNextActivity(isFirstRound: true)
    }
    
    // ⏸️ NEW: Pause functionality
    func pauseTimer() {
        isPaused = true
        timerCancellable?.cancel()
    }
    
    // ▶️ NEW: Resume functionality
    func resumeTimer() {
        isPaused = false
        startTimer() // Restarts the clock from where it left off
    }
    
    // 🛑 NEW: Forces the game to end and jump to the scoreboard
    func forceEndGame() {
        timerCancellable?.cancel()
        isPaused = false
        isSequenceComplete = true
    }
    
    func resetToMenu() {
        timerCancellable?.cancel()
        gamesPlayed = 0
        isSequenceComplete = false
        isPaused = false
    }

    func nextRound(success: Bool) {
        timerCancellable?.cancel()
        gamesPlayed += 1
        pickNextActivity()
    }

    func pickNextActivity(isFirstRound: Bool = false) {
        if gamesPlayed >= totalSequenceLength {
            isSequenceComplete = true
            timerCancellable?.cancel()
            return
        }
        
        if gamesPlayed == (totalSequenceLength - 1) {
            currentGame = .bonus
            timeRemaining = currentGame.timeLimit
            startTimer()
            return
        }
        
        var nextGame = MiniGame.normalGames.randomElement() ?? .stomp
        if !isFirstRound {
            while nextGame == currentGame {
                nextGame = MiniGame.normalGames.randomElement() ?? .stomp
            }
        }
        
        currentGame = nextGame
        timeRemaining = nextGame.timeLimit
        startTimer()
    }

    private func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.timeRemaining -= 0.1
                if self.timeRemaining <= 0 {
                    self.nextRound(success: false)
                }
            }
    }
}
