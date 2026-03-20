import SwiftUI
import Combine

// 🔧 The NEW Enum that controls the timers for each game
enum MiniGame: CaseIterable {
    case stomp, snooze, party, dj
    
    var timeLimit: Double {
        switch self {
        case .stomp: return 4.0
        case .snooze: return 8.0
        case .party: return 5.0
        case .dj: return 6.0
        }
    }
}

class GameDirector: ObservableObject {
    // 🔧 The NEW variable that GamePageView is looking for!
    @Published var currentGame: MiniGame = .stomp
    
    @Published var timeRemaining: Double = 4.0
    @Published var timePerRound: Double = 4.0
    @Published var roundsPlayed: Int = 0
    @Published var isGameOver: Bool = false
    
    let maxRounds: Int = 10
    private var timerCancellable: AnyCancellable?
    
    func start() {
        roundsPlayed = 0
        isGameOver = false
        pickNextActivity(isFirstRound: true)
        startTimer()
    }
    
    func pickNextActivity(isFirstRound: Bool = false) {
        if roundsPlayed >= maxRounds {
            endGame()
            return
        }
        
        var nextGame = MiniGame.allCases.randomElement() ?? .stomp
        if !isFirstRound {
            while nextGame == currentGame {
                nextGame = MiniGame.allCases.randomElement() ?? .stomp
            }
        }
        
        currentGame = nextGame
        timePerRound = nextGame.timeLimit
        timeRemaining = nextGame.timeLimit
        roundsPlayed += 1
    }
    
    private func startTimer() {
        timerCancellable = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard !isGameOver else { return }
        
        timeRemaining -= 0.05
        
        if timeRemaining <= 0 {
            pickNextActivity()
        }
    }
    
    func endGame() {
        isGameOver = true
        timerCancellable?.cancel()
    }
}
