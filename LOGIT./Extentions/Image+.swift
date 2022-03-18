//
//  Image+.swift
//  WorkoutDiaryApp
//
//  Created by Lukas Kaibel on 12.06.21.
//

import SwiftUI


extension Image {
    
    static var hourglass: Image { Image(systemName: "hourglass") }
    
    static var forward: Image { Image(systemName: "forward.fill") }
    
    static var plusCircle: Image { Image(systemName: "plus.circle.fill") }
    
    static var checkmark: Image { Image(systemName: "checkmark") }
    
    static var repetitions: Image { Image(systemName: "multiply") }
    static var weight: Image { Image(systemName: "scalemass") }
    static var time: Image { Image(systemName: "stopwatch") }

    static var average: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(Color.label, lineWidth: 2)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                }
                .stroke(Color.label, lineWidth: 2)
            }
        }.aspectRatio(1.0, contentMode: .fit)
    }
    
}
