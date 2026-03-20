import SwiftUI

struct ResultsPageView: View {
    var score: Int
    var onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("THE LANDLORD CALLED.")
                .font(.largeTitle.bold())
                .foregroundColor(.red)
            
            Text("Total Noise Units: \(score)")
                .font(.title)
                .foregroundColor(.white)
            
            Button("BE ANNOYING AGAIN", action: onRestart)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(50)
        .background(Color.black.opacity(0.8))
        .cornerRadius(20)
    }
}
