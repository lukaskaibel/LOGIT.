//
//  ProgressCircleButton.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 27.11.22.
//

import SwiftUI

struct ProgressCircleButton: View {

    let progress: Float
    let action: () -> Void

    @State private var animationValue: CGFloat = 1.0

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: (progress == 0.0 ? "xmark" : "checkmark"))
                .font(.body.weight(.bold))
                .foregroundColor(
                    progress == 0.0 ? .secondaryLabel : progress == 1.0 ? .white : .accentColor
                )
                .padding(8)
                .background(
                    progress == 0.0
                        ? Color.fill
                        : progress == 1.0
                            ? .accentColor : .accentColor.secondaryTranslucentBackground
                )
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .trim(from: 0.0, to: CGFloat(progress))
                        .rotation(Angle(degrees: -90))
                        .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                }
                .animation(.easeOut(duration: 0.3), value: animationValue)
                .onAppear {
                    animationValue = 1.0
                }
        }
    }

    // MARK: - Constants

    private let lineWidth: CGFloat = 3

}

struct ProgressCircleButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 50) {
            ProgressCircleButton(progress: 0.0, action: {})
            ProgressCircleButton(progress: 0.4, action: {})
            ProgressCircleButton(progress: 1.0, action: {})
        }
    }
}
