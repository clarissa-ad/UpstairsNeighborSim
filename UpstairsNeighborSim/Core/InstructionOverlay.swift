import SwiftUI

// 🏗️ HELPER VIEW: The 1.5 Second Instruction Pop-up
struct InstructionOverlay: View {
    let actionWord: String
    let description: String
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                Text(actionWord)
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.5), radius: 15)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
