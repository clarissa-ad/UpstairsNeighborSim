import SwiftUI
import Combine

// 1. THE DATABASE: Centralized Metadata for all games
enum MiniGame: CaseIterable {
    case stomp, snooze, party, dj, cymbals, bonus
    
    // 🔧 THE FIX: A specific pool of games that excludes the Bonus Stage
    static var normalGames: [MiniGame] {
        return [.stomp, .snooze, .party, .dj, .cymbals]
    }
    
    // Instruction text that appears in the HUD
    var instruction: String {
        switch self {
        case .stomp: return "STOMP!"
        case .snooze: return "SNOOZE!"
        case .party: return "WAVE!"
        case .dj: return "SCRATCH!"
        case .cymbals: return "CLAP!"
        case .bonus: return "BONUS STAGE!"
        }
    }
    
    // The specific time limit for each game
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
    @Published var isSequenceComplete: Bool = false // Tells the View when the whole game is over
    let totalSequenceLength: Int = 5 // Configurable: 4 random games + 1 bonus = 5 total
    private var gamesPlayed: Int = 0 // Tracks how many games we've finished
    
    private var timerCancellable: AnyCancellable?
    
    func start() {
        gamesPlayed = 0
        isSequenceComplete = false
        pickNextActivity(isFirstRound: true)
    }

    func nextRound(success: Bool) {
        timerCancellable?.cancel()
        
        // We just finished a game, so add 1 to the counter
        gamesPlayed += 1
        
        pickNextActivity()
    }

    func pickNextActivity(isFirstRound: Bool = false) {
        
        // 🛑 STEP 1: Check if the sequence is completely over (Bonus is done)
        if gamesPlayed >= totalSequenceLength {
            isSequenceComplete = true
            timerCancellable?.cancel()
            return // Stop generating new games!
        }
        
        // 🎁 STEP 2: Check if it's time for the Bonus Stage (The final game)
        if gamesPlayed == (totalSequenceLength - 1) {
            currentGame = .bonus
            timeRemaining = currentGame.timeLimit
            startTimer()
            return // Skip the random picking
        }
        
        // 🎲 STEP 3: Otherwise, pick a normal random game
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
