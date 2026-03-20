import SwiftUI
import Combine

class GameDirector: ObservableObject {
    @Published var currentActivity: ActivityType = .stomp
    @Published var timeRemaining: Double = 4.0
    @Published var roundsPlayed: Int = 0
    @Published var isGameOver: Bool = false
    
    let timePerRound: Double = 4.0
    let maxRounds: Int = 10 // Ends the game and calls the Landlord after 10 micro-games
    
    private var timerCancellable: AnyCancellable?
    
    func start() {
        roundsPlayed = 0
        isGameOver = false
        pickNextActivity()
        startTimer()
    }
    
    func pickNextActivity() {
        if roundsPlayed >= maxRounds {
            endGame()
            return
        }
        
        // Pick a random game from your ActivityType enum
        currentActivity = ActivityType.allCases.randomElement() ?? .stomp
        timeRemaining = timePerRound
        roundsPlayed += 1
    }
    
    private func startTimer() {
        // Ticks every 0.05 seconds for smooth progress bar animation
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
            // Time is up! Instantly swap to the next game.
            pickNextActivity()
        }
    }
    
    func endGame() {
        isGameOver = true
        timerCancellable?.cancel()
    }
}
