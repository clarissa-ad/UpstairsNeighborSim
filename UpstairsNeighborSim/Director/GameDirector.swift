import SwiftUI
import Combine

// 1. THE DATABASE: Centralized Metadata for all games
enum MiniGame: CaseIterable {
    case stomp, snooze, party, dj, cymbals, bonus
    
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
    
    private var timerCancellable: AnyCancellable?
    
    func start() {
        pickNextActivity(isFirstRound: true)
    }

    func nextRound(success: Bool) {
        timerCancellable?.cancel()
        pickNextActivity()
    }

    func pickNextActivity(isFirstRound: Bool = false) {
        var nextGame = MiniGame.allCases.randomElement() ?? .stomp
        
        if !isFirstRound {
            while nextGame == currentGame {
                nextGame = MiniGame.allCases.randomElement() ?? .stomp
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
