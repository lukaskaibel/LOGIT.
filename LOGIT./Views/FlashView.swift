//
//  FlashView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 14.06.23.
//

import SwiftUI

struct FlashView: View {
    private let flashDuration = 0.2
    private let flashRepeatCount = 4
    
    let color: Color
    
    @Binding var shouldFlash: Bool
    
    @State private var isFlashing = false
    
    var body: some View {
        color
            .opacity(isFlashing ? 1 : 0)
            .onChange(of: shouldFlash) { newValue in
                guard newValue else {
                    withAnimation(Animation.easeInOut(duration: flashDuration)) {
                        isFlashing = false
                    }
                    return
                }
                withAnimation(Animation.easeInOut(duration: flashDuration).repeatCount(flashRepeatCount, autoreverses: true)) {
                    isFlashing = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration * Double(flashRepeatCount)) {
                    shouldFlash = false
                }
            }
    }
}

struct FlashView_Previews: PreviewProvider {
    static var previews: some View {
        FlashView(color: .accentColor, shouldFlash: .constant(true))
    }
}
